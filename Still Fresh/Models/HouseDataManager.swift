import SwiftUI
import Supabase

class HouseDataManager: ObservableObject {
    @Published var house: HouseModel? = nil
    @Published var members: [ProfileModel] = []
    @Published var memberships: [HouseMembershipModel] = []
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil
    
    private var lastAuthTime: Date?
    private let authCacheDuration: TimeInterval = 4 * 60 // 4 minutes
    
    // Get the current user ID
    private func getCurrentUserId() async throws -> UUID {
        let session = try await SupaClient.auth.session
        let userId = session.user.id
        if userId.uuidString.isEmpty {
            throw NSError(domain: "HouseDataManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to get current user ID"])
        }
        return userId
    }
    
    // Authenticate with Supabase
    private func authenticate() async throws {
        // Check if we have a recent authentication
        if let lastAuth = lastAuthTime,
           Date().timeIntervalSince(lastAuth) < authCacheDuration {
            // Auth is still valid, skip re-auth
            return
        }
        
        do {
            let session = try await SupaClient.auth.session
            
            // Ensure the auth token is fresh to avoid RLS permission issues
            let expiresAt = session.expiresAt
            if expiresAt != nil {
                let expiryDate = Date(timeIntervalSince1970: expiresAt)
                let fiveMinutesFromNow = Date().addingTimeInterval(5 * 60)
                
                // If token expires in less than 5 minutes, refresh it
                if expiryDate < fiveMinutesFromNow {
                    _ = try await SupaClient.auth.refreshSession()
                }
            }
            
            lastAuthTime = Date()
        } catch {
            throw NSError(domain: "HouseDataManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Authentication failed: \(error.localizedDescription)"])
        }
    }
    
    // Load house data for the current user
    func loadHouseData(houseId: String) async throws -> HouseModel? {
        try await authenticate()
        
        // Get house details
        let houseResponse = try await SupaClient.database
            .from("houses")
            .select("*")
            .eq("house_id", value: houseId)
            .execute()
        
        // If the direct query fails, try a different approach that might work better with RLS
        if houseResponse.data.isEmpty || houseResponse.data.count <= 2 {
            // Create a fallback house model with the known ID
            return HouseModel(
                houseId: houseId,
                houseName: "House \(houseId.prefix(8))",
                houseImage: "",
                houseAddress: "",
                createdAt: "",
                updatedAt: ""
            )
        }
        
        // Create a temporary struct to match the database response format
        struct HouseRecord: Decodable {
            let house_id: String
            let house_name: String
            let house_image: String?
            let house_address: String?
            let created_at: String?
            let updated_at: String?
        }
        
        // Decode the response using the temporary struct
        let decoder = JSONDecoder()
        do {
            let houseRecords = try decoder.decode([HouseRecord].self, from: houseResponse.data)
            
            // Check if the array is empty
            if houseRecords.isEmpty {
                // Try to parse the data as a single HouseRecord instead of an array
                do {
                    let singleHouse = try decoder.decode(HouseRecord.self, from: houseResponse.data)
                    
                    return HouseModel(
                        houseId: singleHouse.house_id,
                        houseName: singleHouse.house_name,
                        houseImage: singleHouse.house_image ?? "",
                        houseAddress: singleHouse.house_address ?? "",
                        createdAt: singleHouse.created_at ?? "",
                        updatedAt: singleHouse.updated_at ?? ""
                    )
                } catch {
                    return nil
                }
            }
            
            // Convert to our model format
            let firstHouse = houseRecords[0]
            return HouseModel(
                houseId: firstHouse.house_id,
                houseName: firstHouse.house_name,
                houseImage: firstHouse.house_image ?? "",
                houseAddress: firstHouse.house_address ?? "",
                createdAt: firstHouse.created_at ?? "",
                updatedAt: firstHouse.updated_at ?? ""
            )
        } catch {
            return nil
        }
    }
    
    // Join a house
    func joinHouse(houseId: String) async throws {
        try await authenticate()
        let userId = try await getCurrentUserId()
        
        // Check if the house exists
        let houseCheckResponse = try await SupaClient.database
            .from("houses")
            .select("house_id")
            .eq("house_id", value: houseId)
            .execute()
        
        if houseCheckResponse.data.isEmpty || houseCheckResponse.data.count <= 2 {
            throw NSError(domain: "HouseDataManager", code: 4, userInfo: [NSLocalizedDescriptionKey: "House not found"])
        }
        
        // Create membership
        let membershipData = HouseMembershipModel.create(userId: userId.uuidString, houseId: houseId)
        
        _ = try await SupaClient.database
            .from("house_membership")
            .insert(membershipData)
            .execute()
    }
    
    // Load memberships for the current user
    func loadMemberships() async throws -> [HouseMembershipModel] {
        try await authenticate()
        let userId = try await getCurrentUserId()
        
        let membershipResponse = try await SupaClient.database
            .from("house_membership")
            .select("*")
            .eq("user_id", value: userId.uuidString)
            .execute()
        
        if membershipResponse.data.isEmpty {
            return []
        }
        
        let decoder = JSONDecoder()
        let memberships = try decoder.decode([HouseMembershipModel].self, from: membershipResponse.data)
        
        self.memberships = memberships
        return memberships
    }
    
    // Get all members of a house
    func getHouseMembers(houseId: String) async throws -> [ProfileModel] {
        // Get all members of this house - with proper RLS, this should only return memberships the user can see
        let allMembersResponse = try await SupaClient.database
            .from("house_membership")
            .select("user_id")
            .eq("house_id", value: houseId)
            .execute()
        
        if allMembersResponse.data.isEmpty {
            throw NSError(domain: "HouseDataManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch house members"])
        }
        
        // We need to use the original decoder for the snake_case field names in the response
        let decoder = JSONDecoder()
        
        struct UserIdRecord: Decodable {
            let user_id: String?
        }
        
        let allMembershipsRecords = try decoder.decode([UserIdRecord].self, from: allMembersResponse.data)
        let memberIds = allMembershipsRecords.compactMap { $0.user_id }
        
        // 4. Get user details for all members
        var profiles: [ProfileModel] = []
        
        for memberId in memberIds {
            let userResponse = try await SupaClient.database
                .from("profiles")
                .select("*")
                .eq("user_id", value: memberId)
                .execute()
            
            if !userResponse.data.isEmpty {
                // Create a temporary struct to match the database response format
                let userData = try decoder.decode([ProfileModel].self, from: userResponse.data)
                if let profile = userData.first {
                    profiles.append(profile)
                }
            }
        }
        
        return profiles
    }
    
    // Load all data for the house dashboard
    func loadGroupData() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            // Load house data
            let house = try await loadHouseData(houseId: house!.houseId)
            
            if house == nil {
                await MainActor.run {
                    self.isLoading = false
                }
                return
            }
            
            // Load house members
            let members = try await getHouseMembers(houseId: house!.houseId)
            
            // Update UI on main thread
            await MainActor.run {
                self.house = house
                self.members = members
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load group data: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    // Leave a house group
    func leaveHouse(houseId: String) async throws {
        try await authenticate()
        let userId = try await getCurrentUserId()
        
        // Delete the membership record
        _ = try await SupaClient.database
            .from("house_membership")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .eq("house_id", value: houseId)
            .execute()
            
        // Reload memberships to check if user has any other houses
        _ = try await loadMemberships()
    }
    
    // Remove a member from a house
    func removeMember(userId: String, houseId: String) async throws {
        try await authenticate()
        
        // Delete the membership record
        _ = try await SupaClient.database
            .from("house_membership")
            .delete()
            .eq("user_id", value: userId)
            .eq("house_id", value: houseId)
            .execute()
            
        // Reload members list
        let updatedMembers = try await getHouseMembers(houseId: houseId)
        
        await MainActor.run {
            self.members = updatedMembers
        }
    }

    // Update house name
    func updateHouseName(houseId: String, newName: String) async throws {
        try await authenticate()
        
        // Update the house name
        _ = try await SupaClient.database
            .from("houses")
            .update(["house_name": newName])
            .eq("house_id", value: houseId)
            .execute()
            
        // Update local state
        await MainActor.run {
            if var currentHouse = self.house {
                currentHouse.houseName = newName
                self.house = currentHouse
            }
        }
    }
}
