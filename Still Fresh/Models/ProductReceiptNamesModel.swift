//
//  ProductReceiptNamesModel.swift
//  Still Fresh
//
//  Created by Jesse van der Voet on 19/05/2025.
//

struct ProductReceiptNameModel: Decodable {
    let id: String
    let createdAt: String
    let updatedAt: String
    let productId: String
    let productReceiptName: String?
}
