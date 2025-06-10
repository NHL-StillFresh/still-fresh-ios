import SwiftUI

@MainActor
class GroupSelectionManager: ObservableObject {
    @AppStorage("selectedGroupId") private var storedGroupId: String?
    
    @Published var selectedGroupId: String? {
        didSet {
            if let id = selectedGroupId, isValidUUID(id) {
                storedGroupId = id
            } else {
                selectedGroupId = nil
                storedGroupId = nil
            }
        }
    }
    @Published var userGroups: [GroupModel] = []
    @Published var members: [ProfileModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var joinGroupId: String = ""
    @Published var isJoiningGroup: Bool = false
    @Published var joinSuccess: Bool = false
    
    private let dataManager: HouseDataManager
    
    init(dataManager: HouseDataManager = HouseDataManager()) {
        self.dataManager = dataManager
        // Validate stored ID on init
        if let id = storedGroupId, isValidUUID(id) {
            self.selectedGroupId = id
        } else {
            self.selectedGroupId = nil
            self.storedGroupId = nil
        }
    }
    
    // Helper function to validate UUID format
    private func isValidUUID(_ string: String) -> Bool {
        let uuidRegex = "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
        let uuidPredicate = NSPredicate(format: "SELF MATCHES %@", uuidRegex)
        return uuidPredicate.evaluate(with: string)
    }
    
    func loadUserGroups() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let memberships = try await dataManager.loadMemberships()
            var groups: [GroupModel] = []
            var seenGroupIds = Set<String>() // Track unique group IDs
            
            for membership in memberships {
                if isValidUUID(membership.groupId) && !seenGroupIds.contains(membership.groupId),
                   let house = try await dataManager.loadHouseData(houseId: membership.groupId) {
                    seenGroupIds.insert(membership.groupId)
                    groups.append(house.asGroup)
                }
            }
            
            self.userGroups = groups
            
            // If we have a stored group ID, verify it exists in the loaded groups
            if let storedId = storedGroupId, isValidUUID(storedId) {
                if groups.contains(where: { $0.groupId == storedId }) {
                    self.selectedGroupId = storedId
                } else {
                    // If stored group no longer exists, clear it
                    self.selectedGroupId = nil
                }
            } else if !groups.isEmpty {
                // If no stored group, select the first one
                self.selectedGroupId = groups[0].groupId
            }
            
            // Load members for selected group
            await loadGroupMembers()
            
            self.isLoading = false
        } catch {
            print("Failed to load groups: \(error)")
            self.errorMessage = "Failed to load groups: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    func loadGroupMembers() async {
        guard let groupId = selectedGroupId, isValidUUID(groupId) else { return }
        
        do {
            self.members = try await dataManager.getHouseMembers(houseId: groupId)
        } catch {
            print("Failed to load members: \(error)")
            self.errorMessage = "Failed to load members: \(error.localizedDescription)"
        }
    }
    
    func selectGroup(_ groupId: String) {
        guard isValidUUID(groupId) else {
            errorMessage = "Invalid group ID format"
            return
        }
        selectedGroupId = groupId
        Task {
            await loadGroupMembers()
        }
    }
    
    func joinGroup() async {
        guard !joinGroupId.isEmpty else { return }
        
        // Validate UUID format before attempting to join
        guard isValidUUID(joinGroupId) else {
            errorMessage = "Invalid group ID format. Please enter a valid ID."
            return
        }
        
        isJoiningGroup = true
        errorMessage = nil
        
        do {
            try await dataManager.joinHouse(houseId: joinGroupId)
            joinSuccess = true
            
            // Reload groups after joining
            await loadUserGroups()
            
            // Clear join form
            joinGroupId = ""
            isJoiningGroup = false
            
            // Auto-select the newly joined group
            selectGroup(joinGroupId)
        } catch {
            errorMessage = "Failed to join group: \(error.localizedDescription)"
            isJoiningGroup = false
        }
    }
    
    var selectedGroup: GroupModel? {
        guard let selectedGroupId = selectedGroupId, isValidUUID(selectedGroupId) else { return nil }
        return userGroups.first { $0.groupId == selectedGroupId }
    }
} 