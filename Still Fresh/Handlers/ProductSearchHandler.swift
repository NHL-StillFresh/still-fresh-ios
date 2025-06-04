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
        
        var products: [ProductModel] = []
        
        for (_, (originalName, product)) in selectedProducts.enumerated() {
            
            do {
                let expiryDays = await ExpiryDateGuessModel().fetchExpiryDateFromAPI(productName: product.title)
                
                let productData = InsertProductModel(
                    product_name: product.title, product_image: product.imageUrl, product_code: nil, product_expiration_in_days: expiryDays, product_nutritional_value: nil, source_id: nil
                )
                
                let response: [ProductModel] = try await SupaClient
                    .from("products")
                    .select()
                    .eq("product_name", value: product.title)
                    .execute()
                    .value

                let exists = (response.count) > 0
                
                var product_id: String = ""
                
                if exists {
                    products.append(response.first!)
                    
                    product_id = response.first!.product_id
                } else {
                    let insertedProduct: ProductModel = try await SupaClient
                        .from("products")
                        .insert(productData)
                        .select()
                        .single()
                        .execute()
                        .value
                    
                    products.append(insertedProduct)
                    
                    product_id = insertedProduct.product_id
                }
                
                let productReceiptNameData: [String: String] = [
                    "product_receipt_name": originalName,
                    "product_id": product_id
                ]
                
                try await SupaClient
                    .from("product_receipt_names")
                    .insert(productReceiptNameData)
                    .execute()
                
            } catch {
                print("Error pushing unknown products: \(error)")
                return false
            }
        }
        
        for knownProduct in knownProducts {
            do {
                let response: [ProductModel] = try await SupaClient
                    .from("products")
                    .select()
                    .eq("product_name", value: knownProduct)
                    .execute()
                    .value

                let exists = (response.count) > 0
                
                if exists {
                    products.append(response.first!)
                    continue
                }
                
                let singleReceiptProduct: ProductReceiptNameModel = try await SupaClient
                    .from("product_receipt_names")
                    .select()
                    .eq("product_receipt_name", value: knownProduct)
                    .limit(1)
                    .single()
                    .execute()
                    .value
                
                let singleProduct: ProductModel = try await SupaClient
                    .from("products")
                    .select()
                    .eq("product_id", value: singleReceiptProduct.product_id)
                    .limit(1)
                    .single()
                    .execute()
                    .value
                
                products.append(singleProduct)
                
            } catch {
                print("Error pushing known products: \(error)")
                return false
            }
        }
        
        await AddToBasketHandler.addToBasket(products: products)
        
        return true
    }
}
