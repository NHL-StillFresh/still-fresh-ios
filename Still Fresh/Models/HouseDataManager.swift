import SwiftUI
import Supabase

class HouseDataManager: ObservableObject {
    @Published var house: HouseModel? = nil
    @Published var members: [ProfileModel] = []
    @Published var memberships: [GroupMembershipModel] = []
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil
    @Published var showJoinGroupView = false
    @Published var joinGroupId = ""
    @Published var isJoiningGroup = false
    @Published var joinSuccess = false
    
    private let authEmail = "elmedin@test.nl"
    private let authPassword = "elmedin123"
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
                    do {
                        _ = try await SupaClient.auth.refreshSession()
                    } catch {
                        // Continue with the current token, but it might expire soon
                    }
                }
            }
            
            lastAuthTime = Date()
        } catch {
            do {
                // Try to sign in with the stored credentials
                _ = try await SupaClient.auth.signIn(
                    email: authEmail,
                    password: authPassword
                )
                lastAuthTime = Date()
            } catch {
                throw NSError(domain: "HouseDataManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Authentication failed"])
            }
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
                houseAddress: "",
                houseName: "House \(houseId.prefix(8))",
                houseImage: "",
                createdAt: "",
                updatedAt: "",
                houseId: houseId
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
                        houseAddress: singleHouse.house_address ?? "",
                        houseName: singleHouse.house_name,
                        houseImage: singleHouse.house_image ?? "",
                        createdAt: singleHouse.created_at ?? "",
                        updatedAt: singleHouse.updated_at ?? "",
                        houseId: singleHouse.house_id
                    )
                } catch {
                    return nil
                }
            }
            
            // Convert to our model format
            let firstHouse = houseRecords[0]
            return HouseModel(
                houseAddress: firstHouse.house_address ?? "",
                houseName: firstHouse.house_name,
                houseImage: firstHouse.house_image ?? "",
                createdAt: firstHouse.created_at ?? "",
                updatedAt: firstHouse.updated_at ?? "",
                houseId: firstHouse.house_id
            )
        } catch {
            return nil
        }
    }
    
    // Load memberships for the current user
    func loadMemberships() async throws -> [GroupMembershipModel] {
        try await authenticate()
        let userId = try await getCurrentUserId()
        
        // Get user's memberships
        let membershipResponse = try await SupaClient.database
            .from("house_membership")
            .select("*")
            .eq("user_id", value: userId.uuidString)
            .execute()
        
        if membershipResponse.data.isEmpty {
            return []
        }
        
        // Create a temporary struct to match the database response format
        struct MembershipRecord: Decodable {
            let user_id: String
            let house_id: String
        }
        
        // Decode the response using the temporary struct
        let decoder = JSONDecoder()
        let membershipRecords = try decoder.decode([MembershipRecord].self, from: membershipResponse.data)
        
        // Convert to our model format
        let memberships = membershipRecords.map { record in
            GroupMembershipModel(userId: record.user_id, groupId: record.house_id)
        }
        
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
    
    // Join a house group
    func joinHouse(houseId: String) async throws {
        // Authenticate first
        try await authenticate()
        let userId = try await getCurrentUserId()
        
        // Check if the house exists - with RLS, we need to join with memberships to ensure access
        let houseCheckResponse = try await SupaClient.database
            .from("houses")
            .select("house_id")
            .eq("house_id", value: houseId)
            .execute()
        
        // Check if the data is empty or just contains empty brackets []
        if houseCheckResponse.data.isEmpty || houseCheckResponse.data.count <= 2 {
            throw NSError(domain: "HouseDataManager", code: 4, userInfo: [NSLocalizedDescriptionKey: "House not found with ID: \(houseId)"])
        }
        
        // Create the membership record
        let membershipData: [String: String] = [
            "user_id": userId.uuidString,
            "house_id": houseId
        ]
        
        // Execute the insert operation
        _ = try await SupaClient.database
            .from("house_membership")
            .insert(membershipData)
            .execute()
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
                    self.showJoinGroupView = true
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
    
    // Join a group with the provided ID
    func joinGroup() {
        guard !joinGroupId.isEmpty else { return }
        
        isJoiningGroup = true
        
        Task {
            do {
                try await joinHouse(houseId: joinGroupId)
                
                // Success - show success message and reload data
                await MainActor.run {
                    self.isJoiningGroup = false
                    self.joinSuccess = true
                    
                    // After a short delay, hide success message and load group data
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.joinSuccess = false
                        self.showJoinGroupView = false
                        Task {
                            await self.loadGroupData()
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to join group: \(error.localizedDescription)"
                    self.isJoiningGroup = false
                }
            }
        }
    }
}
