//
//  HouseMemberships.swift
//  Still Fresh
//
//  Created by Jesse van der Voet on 19/05/2025.
//

struct HouseMembershipModel: Decodable {
    let userId: String
    let houseId: String
    let membershipJoinDate: String
    let membershipType: String
    let createdAt: String
    let updatedAt: String
}
