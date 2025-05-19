//
//  ProductModel.swift
//  Still Fresh
//
//  Created by Jesse van der Voet on 19/05/2025.
//

struct ProductModel: Decodable {
    let product_name: String
    let product_image: String?
    let product_code: String?
    let product_expiration_in_days: Int?
    let product_nutritional_value: String?
    let source_id: String?
    let created_at: String?
    let updated_at: String?
    let product_id: String
}
