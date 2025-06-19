//
//  AddToBasketHandler.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 04/06/2025.
//

import SwiftUI

class BasketHandler {
    @AppStorage("selectedHouseId") private static var houseId: String = ""

    
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
                    house_id: houseId,
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
        
        await setProductNotificationsFromBasket();
    }
    
    public static func getAllBasketProducts() async throws -> [HouseInventoryModelWithProducts] {
        let result: [HouseInventoryModelWithProducts] = try await SupaClient
            .from("house_inventories")
            .select("""
                    house_inventory_id,
                    product_id,
                    inventory_quantity,
                    inventory_best_before_date,
                    inventory_purchase_date,
                    created_at,
                    products (
                        product_name,
                        product_image,
                        product_code,
                        product_expiration_in_days,
                        product_nutritional_value,
                        source_id,
                        created_at,
                        updated_at,
                        product_id
                    )
                    """)
            .eq("house_id", value: BasketHandler.houseId)
            .execute()
            .value
        
        return result
    }
    
    public static func getBasketProductsSortedOnHeader() async throws -> [BasketSectionHeader: [FoodItem]] {
        let result: [HouseInventoryModelWithProducts] = try await SupaClient
            .from("house_inventories")
            .select("""
                    house_inventory_id,
                    product_id,
                    inventory_quantity,
                    inventory_best_before_date,
                    inventory_purchase_date,
                    created_at,
                    products (
                        product_name,
                        product_image,
                        product_code,
                        product_expiration_in_days,
                        product_nutritional_value,
                        source_id,
                        created_at,
                        updated_at,
                        product_id
                    )
                    """)
            .eq("house_id", value: houseId)
            .execute()
            .value
    
        var groupedItems: [BasketSectionHeader: [FoodItem]] = [:]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        for resultItem in result {
            guard let expiryDate = dateFormatter.date(from: resultItem.inventory_best_before_date) else {
                continue
            }
            
            let expiryDay = Calendar.current.startOfDay(for: expiryDate)
            
            let section: BasketSectionHeader
            if expiryDay == today {
                section = .today
            } else if expiryDay == tomorrow {
                section = .tomorrow
            } else {
                section = .later
            }
            
            let foodItem = FoodItem(
                id: UUID(),
                house_inventory_id: resultItem.house_inventory_id,
                name: resultItem.products.product_name,
                store: "Unknown",
                image: resultItem.products.product_image,
                expiryDate: expiryDate
            )
            
            groupedItems[section, default: []].append(foodItem)
        }
                
        return groupedItems
    }
    
    public static func getBasketProducts() async throws -> [FoodItem] {
        let result: [HouseInventoryModelWithProducts] = try await SupaClient
            .from("house_inventories")
            .select("""
                    house_inventory_id,
                    product_id,
                    inventory_quantity,
                    inventory_best_before_date,
                    inventory_purchase_date,
                    created_at,
                    products (
                        product_name,
                        product_image,
                        product_code,
                        product_expiration_in_days,
                        product_nutritional_value,
                        source_id,
                        created_at,
                        updated_at,
                        product_id
                    )
                    """)
            .eq("house_id", value: BasketHandler.houseId)
            .execute()
            .value
    
        var foodItems: [FoodItem] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        for resultItem in result {
            guard let expiryDate = dateFormatter.date(from: resultItem.inventory_best_before_date) else {
                continue
            }
            
            let foodItem = FoodItem(
                id: UUID(),
                house_inventory_id: resultItem.house_inventory_id,
                name: resultItem.products.product_name,
                store: "Unknown",
                image: resultItem.products.product_image,
                expiryDate: expiryDate
            )
            
            foodItems.append(foodItem)
        }
        
        return foodItems
    }
    
    public static func deleteInventoryItem(houseInventoryId: Int) async throws {
        do {
            let result = try await SupaClient
                .from("house_inventories")
                .delete()
                .eq("house_inventory_id", value: houseInventoryId)
                .execute()
            
            print("Successfully deleted inventory item with ID: \(houseInventoryId)")
            
            await setProductNotificationsFromBasket()
        } catch {
            print("Error deleting inventory item: \(error)")
            throw error
        }
    }
    
    public static func deleteMultipleInventoryItems(houseInventoryIds: [Int]) async throws {
        do {
            for houseInventoryId in houseInventoryIds {
                let result = try await SupaClient
                    .from("house_inventories")
                    .delete()
                    .eq("house_inventory_id", value: houseInventoryId)
                    .execute()
            }
            
            print("Successfully deleted \(houseInventoryIds.count) inventory items")
            
            await setProductNotificationsFromBasket()
        } catch {
            print("Error deleting multiple inventory items: \(error)")
            throw error
        }
    }
}
