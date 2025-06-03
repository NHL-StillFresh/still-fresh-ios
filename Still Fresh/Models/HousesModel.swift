//
//  HousesModel.swift
//  Still Fresh
//
//  Created by Jesse van der Voet on 19/05/2025.
//

struct HouseModel: Decodable {
    let houseAddress: String?
    let houseName: String
    let houseImage: String
    let createdAt: String
    let updatedAt: String
    let houseId: String
}
