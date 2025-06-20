//
//  HousesModel.swift
//  Still Fresh
//
//  Created by Jesse van der Voet on 19/05/2025.
//

struct GroupModel: Decodable {
    let groupId: String
    let groupName: String
    let groupImage: String
    let groupAddress: String?
    let createdAt: String
    let updatedAt: String
    
    init(groupId: String, groupName: String, groupImage: String = "", groupAddress: String? = nil, createdAt: String, updatedAt: String) {
        self.groupId = groupId
        self.groupName = groupName
        self.groupImage = groupImage
        self.groupAddress = groupAddress
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct HouseModel: Codable {
    let houseId: String
    var houseName: String
    let houseImage: String
    let houseAddress: String
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case houseId = "house_id"
        case houseName = "house_name"
        case houseImage = "house_image"
        case houseAddress = "house_address"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

extension HouseModel {
    var asGroup: GroupModel {
        GroupModel(
            groupId: houseId,
            groupName: houseName,
            groupImage: houseImage,
            groupAddress: houseAddress,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension GroupModel {
    init(fromHouse house: HouseModel) {
        self.init(
            groupId: house.houseId,
            groupName: house.houseName,
            groupImage: house.houseImage,
            groupAddress: house.houseAddress,
            createdAt: house.createdAt,
            updatedAt: house.updatedAt
        )
    }
}
