//
//  HouseInventoriesModel.swift
//  Still Fresh
//
//  Created by Jesse van der Voet on 19/05/2025.
//

struct HouseInventoryModel: Decodable {
    let houseInventoryId: String
    let inventoryType: String?
    let houseId: String
    let productId: String
    let inventoryQuantity: Int
    let inventoryBestBeforeDate: String
    let inventoryPurchaseDate: String?
    let createdAt: String
    let updatedAt: String
}
