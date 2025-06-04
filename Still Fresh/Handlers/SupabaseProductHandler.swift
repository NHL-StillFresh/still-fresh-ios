//
//  SupabaseProductHandler.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 04/06/2025.
//

import SwiftUI

class SupabaseProductHandler {
    static func findProductByName(_ name: String) async throws -> ProductModel? {
        let response: [ProductModel] = try await SupaClient
            .from("products")
            .select()
            .eq("product_name", value: name)
            .limit(1)
            .execute()
            .value
        
        return response.first
    }
    
    public static func addOrFetchProduct(
        title: String,
        imageUrl: String?,
        expirationDays: Int
    ) async throws -> ProductModel {
        
        let existing: [ProductModel] = try await SupaClient
            .from("products")
            .select()
            .eq("product_name", value: title)
            .limit(1)
            .execute()
            .value

        if let found = existing.first {
            return found
        }

        let productToInsert = InsertProductModel(
            product_name: title,
            product_image: imageUrl,
            product_code: nil,
            product_expiration_in_days: expirationDays,
            product_nutritional_value: nil,
            source_id: nil
        )
        
        let inserted: ProductModel = try await SupaClient
            .from("products")
            .insert(productToInsert)
            .select()
            .single()
            .execute()
            .value
        
        return inserted
    }
    
    public static func addOrFetchReceiptName(
        receiptName: String,
        productId: String
    ) async throws -> ProductReceiptNameModel {
        
        let existing: [ProductReceiptNameModel] = try await SupaClient
            .from("product_receipt_names")
            .select()
            .eq("product_receipt_name", value: receiptName)
            .limit(1)
            .execute()
            .value

        if let found = existing.first {
            return found
        }

        let insertData: [String: String] = [
            "product_receipt_name": receiptName,
            "product_id": productId
        ]

        let inserted: ProductReceiptNameModel = try await SupaClient
            .from("product_receipt_names")
            .insert(insertData)
            .select()
            .single()
            .execute()
            .value
        
        return inserted
    }


}
