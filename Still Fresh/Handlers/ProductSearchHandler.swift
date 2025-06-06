//
//  ProductSearchHandler.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 03/06/2025.
//

class ProductSearchHandler {
    
    public static func searchForProduct(productName: String) async -> JumboSearchResponse? {
        do {
            return try await JumboService().searchProducts(query: productName)
        } catch {
            return nil
        }
    }
    
    public static func checkSingleProduct(productName: String) async ->  ProductKnownStatus {
        do {
            let product: ProductReceiptNameModel = try await SupaClient
                .from("product_receipt_names")
                .select()
                .eq("product_receipt_name", value: productName)
                .limit(1)
                .single()
                .execute()
                .value
            
            print("Product receipt name: \(product.product_receipt_name)")
            
            let productKnownName: ProductModel = try await SupaClient
                .from("products")
                .select()
                .eq("product_id", value: product.product_id)
                .limit(1)
                .single()
                .execute()
                .value
            
            print("Product Known Name: \(productKnownName.product_name)")
            
            return .known
            
        } catch {
            print("Error: \(error)")
            return .unknown
        }
    }
}
