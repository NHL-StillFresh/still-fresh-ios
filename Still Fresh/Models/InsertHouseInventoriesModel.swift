//
//  InsertHouseInventoriesModel.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 04/06/2025.
//


struct InsertHouseInventoryModel: Codable {
    let house_id: String
    let product_id: String
    let inventory_quantity: Int
    let inventory_best_before_date: String
    let inventory_purchase_date: String?
}
