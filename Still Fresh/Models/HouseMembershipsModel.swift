//
//  GroupMembershipModel.swift
//  Still Fresh
//

struct GroupMembershipModel: Decodable {
    let userId: String
    let groupId: String
    
    init(userId: String, groupId: String) {
        self.userId = userId
        self.groupId = groupId
    }
}

// For backward compatibility
typealias HouseMembershipModel = GroupMembershipModel

extension GroupMembershipModel {
    // Computed property for backward compatibility
    var houseId: String {
        return groupId
    }
    
    // Initializer for backward compatibility
    init(fromHouseMembership membership: GroupMembershipModel) {
        self.userId = membership.userId
        self.groupId = membership.groupId
    }
}
