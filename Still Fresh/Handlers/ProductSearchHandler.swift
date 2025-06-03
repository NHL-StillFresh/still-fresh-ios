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
    
    public static func addAllSelectedProducts(selectedProducts: [String: JumboProduct], knownProducts: [String]) async -> Bool {
        guard !selectedProducts.isEmpty || !knownProducts.isEmpty else {
            return false
        }
        
        do {
            for (_, (originalName, product)) in selectedProducts.enumerated() {
                
                do {
                    try await SupaClient
                        .from("products")
                        .select()
                        .eq("product_name", value: originalName)
                        .limit(1)
                        .single()
                        .execute()
                } catch {
                    let expiryDays = await ExpiryDateGuessModel().fetchExpiryDateFromAPI(productName: product.title)
                    
                    
                    let productData = InsertProductModel(
                        product_name: product.title, product_image: product.imageUrl, product_code: nil, product_expiration_in_days: expiryDays, product_nutritional_value: nil, source_id: nil
                    )
                    
                    let insertedProduct: ProductModel = try await SupaClient
                        .from("products")
                        .insert(productData)
                        .select()
                        .single()
                        .execute()
                        .value
                    
                    let productReceiptNameData: [String: String] = [
                        "product_receipt_name": originalName,
                        "product_id": String(insertedProduct.product_id)
                    ]
                    
                    try await SupaClient
                        .from("product_receipt_names")
                        .insert(productReceiptNameData)
                        .execute()
                }
            }
            
            return true
            
        } catch {
            print("Error: \(error)")
            return false
        }
    }
}
