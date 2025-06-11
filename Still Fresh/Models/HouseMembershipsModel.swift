//
//  GroupMembershipModel.swift
//  Still Fresh
//

import Foundation

struct HouseMembershipModel: Codable {
    let userId: String
    let houseId: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case houseId = "house_id"
    }
    
    static func create(userId: String, houseId: String) -> [String: String] {
        return [
            "user_id": userId,
            "house_id": houseId
        ]
    }
}

// For backward compatibility
typealias GroupMembershipModel = HouseMembershipModel
