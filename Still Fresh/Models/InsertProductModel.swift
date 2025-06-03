//
//  InsertProductModel.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 02/06/2025.
//

struct InsertProductModel: Codable {
    let product_name: String
    let product_image: String?
    let product_code: String?
    let product_expiration_in_days: Int?
    let product_nutritional_value: String?
    let source_id: String?
}
