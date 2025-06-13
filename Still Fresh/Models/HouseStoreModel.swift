import SwiftUI

@MainActor
class HouseStoreModel: ObservableObject {
    static let shared = HouseStoreModel()
    
    private let dataManager: HouseDataManager
    
    @Published var selectedHouse: HouseModel?
    @Published var userHouses: [HouseModel] = []
    @Published var houseMembers: [ProfileModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var joinHouseId: String = ""
    @Published var isJoiningHouse: Bool = false
    @Published var joinSuccess: Bool = false
    
    @AppStorage("selectedHouseId") private var storedHouseId: String?
    
    private init(dataManager: HouseDataManager = HouseDataManager()) {
        self.dataManager = dataManager
        
        // Load stored house ID and data on init
        if let storedId = storedHouseId {
            Task {
                await selectHouse(houseId: storedId)
            }
        }
    }
    
    func loadUserHouses() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let memberships = try await dataManager.loadMemberships()
            var houses: [HouseModel] = []
            
            for membership in memberships {
                if let house = try await dataManager.loadHouseData(houseId: membership.houseId) {
                    houses.append(house)
                }
            }
            
            self.userHouses = houses
            
            // Auto-select first house if none selected
            if selectedHouse == nil, let firstHouse = houses.first {
                await selectHouse(houseId: firstHouse.houseId)
            }
            
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    func selectHouse(houseId: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Try to load the house data
            if let house = try await dataManager.loadHouseData(houseId: houseId) {
                self.selectedHouse = house
                self.storedHouseId = houseId
                
                // Load members
                let members = try await dataManager.getHouseMembers(houseId: houseId)
                self.houseMembers = members
                
                // Update userHouses if this house isn't in the list
                if !userHouses.contains(where: { $0.houseId == houseId }) {
                    await loadUserHouses()
                }
            } else {
                errorMessage = "Failed to load house data"
                self.selectedHouse = nil
                self.storedHouseId = nil
            }
        } catch {
            errorMessage = error.localizedDescription
            self.selectedHouse = nil
            self.storedHouseId = nil
        }
    }
    
    func createHouse(name: String, address: String) async throws {
        let houseData = HouseCreate(
            house_name: name,
            house_address: address,
            house_image: ""
        )
        
        let response = try await SupaClient.database
            .from("houses")
            .insert(houseData)
            .select()
            .execute()
        
        let decoder = JSONDecoder()
        let houses = try decoder.decode([HouseResponse].self, from: response.data)
        
        guard let houseId = houses.first?.house_id else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get house ID"])
        }
        
        // Get the current user ID
        let session = try await SupaClient.auth.session
        let userId = session.user.id
        
        // Create membership
        let membershipData = MembershipCreate(
            user_id: userId.uuidString,
            house_id: houseId
        )
        
        _ = try await SupaClient.database
            .from("house_membership")
            .insert(membershipData)
            .execute()
        
        // Reload houses and select the new one
        await loadUserHouses()
        await selectHouse(houseId: houseId)
    }
    
    func joinHouse() async {
        guard !joinHouseId.isEmpty else { return }
        isJoiningHouse = true
        errorMessage = nil
        
        do {
            // Check if membership already exists
            let memberships = try await dataManager.loadMemberships()
            if memberships.contains(where: { $0.houseId == joinHouseId }) {
                errorMessage = "You are already part of that group!"
                isJoiningHouse = false
                return
            }
            
            try await dataManager.joinHouse(houseId: joinHouseId)
            joinSuccess = true
            
            // Reload houses and select the new one
            await loadUserHouses()
            await selectHouse(houseId: joinHouseId)
            
            joinHouseId = ""
            isJoiningHouse = false
        } catch {
            errorMessage = error.localizedDescription
            isJoiningHouse = false
        }
    }
    
    func leaveHouse(houseId: String) async throws {
        try await dataManager.leaveHouse(houseId: houseId)
        
        // Remove from userHouses
        userHouses.removeAll(where: { $0.houseId == houseId })
        
        // If this was the selected house, clear it
        if selectedHouse?.houseId == houseId {
            selectedHouse = nil
            storedHouseId = nil
            houseMembers = []
            
            // Auto-select first available house
            if let firstHouse = userHouses.first {
                await selectHouse(houseId: firstHouse.houseId)
            }
        }
    }
    
    func removeMember(userId: String, houseId: String) async throws {
        try await dataManager.removeMember(userId: userId, houseId: houseId)
        
        // Reload members
        if selectedHouse?.houseId == houseId {
            let updatedMembers = try await dataManager.getHouseMembers(houseId: houseId)
            self.houseMembers = updatedMembers
        }
    }
    
    func updateHouseName(houseId: String, newName: String) async throws {
        try await dataManager.updateHouseName(houseId: houseId, newName: newName)
        
        // Update local state
        if let index = userHouses.firstIndex(where: { $0.houseId == houseId }) {
            userHouses[index].houseName = newName
        }
        
        if selectedHouse?.houseId == houseId {
            selectedHouse?.houseName = newName
        }
    }
}

// Helper structs for API calls
private struct HouseCreate: Encodable {
    let house_name: String
    let house_address: String
    let house_image: String
}

private struct HouseResponse: Decodable {
    let house_id: String
}

private struct MembershipCreate: Encodable {
    let user_id: String
    let house_id: String
} 
