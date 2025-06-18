//
//  HouseInventoriesModel.swift
//  Still Fresh
//
//  Created by Jesse van der Voet on 19/05/2025.
//

struct HouseInventoryModelWithProducts: Decodable {
    let house_inventory_id: Int
    let product_id: String
    let inventory_quantity: Int
    let inventory_best_before_date: String
    let inventory_purchase_date: String?
    let created_at: String
    let products: ProductModel
}
