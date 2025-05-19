//
//  ProductReceiptNamesModel.swift
//  Still Fresh
//
//  Created by Jesse van der Voet on 19/05/2025.
//

struct ProductReceiptNameModel: Decodable {
    let id: String
    let created_at: String
    let updated_at: String
    let product_id: String
    let product_receipt_name: String?
}
