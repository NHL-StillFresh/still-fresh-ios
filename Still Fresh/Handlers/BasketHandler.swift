//
//  AddToBasketHandler.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 04/06/2025.
//

import SwiftUI

class BasketHandler {
    private static var houseId : String = "a4eada31-0c2a-4754-89db-558a1f6d338e"
    
    public static func addToBasket(products: [ProductModel]) async {
        do {
            let houseRows = products.map({
                product in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"

                guard let bestBeforeDate = Calendar.current.date(
                    byAdding: .day,
                    value: product.product_expiration_in_days ?? 7,
                    to: Date()
                ) else {
                    fatalError("Failed to calculate best before date")
                }

                return InsertHouseInventoryModel(
                    house_id: BasketHandler.houseId,
                    product_id: product.product_id,
                    inventory_quantity: 1,
                    inventory_best_before_date: dateFormatter.string(from: bestBeforeDate),
                    inventory_purchase_date: dateFormatter.string(from: Date())
                )
            })
            
            let result = try await SupaClient.from("house_inventories")
                .insert(houseRows)
                .execute()
            
            print(result)
        } catch {
            print("Error: \(error)")
        }
        
    }
}
