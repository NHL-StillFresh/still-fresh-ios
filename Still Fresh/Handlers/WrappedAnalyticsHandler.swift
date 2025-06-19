import Foundation
import SwiftUI
import Supabase

class WrappedAnalyticsHandler: ObservableObject {
    @Published var currentWrappedData: WrappedData = WrappedData.empty
    @Published var isGenerating: Bool = false
    
    @AppStorage("selectedHouseId") private var houseId: String = ""
    
    private let userDefaults = UserDefaults.standard
    private let wrappedCacheKey = "stillFreshWrappedData"
    
    init() {
        loadCachedWrapped()
    }
    
    // MARK: - Caching
    
    private func loadCachedWrapped() {
        if let data = userDefaults.data(forKey: wrappedCacheKey),
           let cached = try? JSONDecoder().decode(WrappedData.self, from: data) {
            self.currentWrappedData = cached
        }
    }
    
    private func cacheWrapped() {
        if let encoded = try? JSONEncoder().encode(currentWrappedData) {
            userDefaults.set(encoded, forKey: wrappedCacheKey)
        }
    }
    
    // MARK: - Real Data Analytics
    
    func generateWrapped(for year: Int? = nil) async {
        await MainActor.run {
            isGenerating = true
        }
        
        let targetYear = year ?? Calendar.current.component(.year, from: Date())
        
        do {
            // Generate wrapped data from real Supabase data
            let wrappedData = try await generateWrappedDataFromDatabase(year: targetYear)
            
            await MainActor.run {
                self.currentWrappedData = wrappedData
                self.isGenerating = false
                self.cacheWrapped()
            }
        } catch {
            print("Error generating wrapped data: \(error)")
            await MainActor.run {
                self.currentWrappedData = WrappedData.empty
                self.isGenerating = false
            }
        }
    }
    
    private func generateWrappedDataFromDatabase(year: Int) async throws -> WrappedData {
        guard !houseId.isEmpty else {
            throw NSError(domain: "WrappedAnalyticsHandler", code: 1, userInfo: [NSLocalizedDescriptionKey: "No house selected"])
        }
        
        // Calculate year boundaries
        let calendar = Calendar.current
        let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
        let endOfYear = calendar.date(from: DateComponents(year: year + 1, month: 1, day: 1))!
        
        let startDateString = ISO8601DateFormatter().string(from: startOfYear)
        let endDateString = ISO8601DateFormatter().string(from: endOfYear)
        
        // Query house inventories for the selected house and year
        let houseInventories: [HouseInventoryModelWithProducts] = try await SupaClient
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
            .gte("created_at", value: startDateString)
            .lt("created_at", value: endDateString)
            .execute()
            .value
        
        // Calculate metrics
        let totalItemsTracked = houseInventories.count
        let totalItemsSaved = calculateItemsSaved(inventories: houseInventories)
        let moneySaved = calculateMoneySaved(inventories: houseInventories)
        let mostUsedIngredient = findMostUsedIngredient(inventories: houseInventories)
        let averageDaysUntilExpiry = calculateAverageDaysUntilExpiry(inventories: houseInventories)
        let monthlyStats = generateMonthlyStats(inventories: houseInventories, year: year)
        let topCategories = extractTopCategories(inventories: houseInventories)
        let zeroWasteWeeks = calculateZeroWasteWeeks(inventories: houseInventories, year: year)
        
        // Generate achievements based on real data
        let achievements = generateAchievements(
            totalItemsSaved: totalItemsSaved,
            moneySaved: moneySaved,
            zeroWasteWeeks: zeroWasteWeeks,
            totalItemsTracked: totalItemsTracked
        )
        
        // Generate fun insight
        let funInsight = generateFunInsight(
            totalItemsSaved: totalItemsSaved,
            mostUsedIngredient: mostUsedIngredient.name,
            moneySaved: moneySaved
        )
        
        return WrappedData(
            year: year,
            totalItemsSaved: totalItemsSaved,
            moneySaved: moneySaved,
            mostUsedIngredient: mostUsedIngredient.name,
            mostUsedIngredientCount: mostUsedIngredient.count,
            favoriteRecipe: "Custom Recipe", // Can't determine from current data
            zeroWasteWeeks: zeroWasteWeeks,
            totalItemsTracked: totalItemsTracked,
            avgDaysUntilExpiry: averageDaysUntilExpiry,
            topCategories: topCategories,
            monthlyStats: monthlyStats,
            achievements: achievements,
            funInsight: funInsight,
            generatedAt: Date()
        )
    }
    
    private func calculateItemsSaved(inventories: [HouseInventoryModelWithProducts]) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let currentDate = Date()
        var savedItems = 0
        
        for inventory in inventories {
            if let expiryDate = dateFormatter.date(from: inventory.inventory_best_before_date) {
                // If the expiry date has passed, we assume the item was used (saved)
                if expiryDate < currentDate {
                    savedItems += inventory.inventory_quantity
                } else {
                    // For items not yet expired, assume 85% are used based on typical usage patterns
                    savedItems += Int(Double(inventory.inventory_quantity) * 0.85)
                }
            }
        }
        
        return savedItems
    }
    
    private func calculateMoneySaved(inventories: [HouseInventoryModelWithProducts]) -> Double {
        // Estimate money saved based on average product values
        // You could enhance this by adding price data to your products table
        let averageItemValue = 2.50
        let savedItems = calculateItemsSaved(inventories: inventories)
        return Double(savedItems) * averageItemValue
    }
    
    private func findMostUsedIngredient(inventories: [HouseInventoryModelWithProducts]) -> (name: String, count: Int) {
        let productCounts = Dictionary(grouping: inventories, by: { $0.products.product_name })
            .mapValues { inventories in
                inventories.reduce(0) { $0 + $1.inventory_quantity }
            }
        
        let mostUsed = productCounts.max(by: { $0.value < $1.value })
        return (name: mostUsed?.key ?? "No items yet", count: mostUsed?.value ?? 0)
    }
    
    private func calculateAverageDaysUntilExpiry(inventories: [HouseInventoryModelWithProducts]) -> Double {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var totalDays = 0.0
        var validItems = 0
        
        for inventory in inventories {
            if let purchaseDate = inventory.inventory_purchase_date,
               let purchaseDateObj = dateFormatter.date(from: purchaseDate),
               let expiryDate = dateFormatter.date(from: inventory.inventory_best_before_date) {
                
                let daysDifference = Calendar.current.dateComponents([.day], from: purchaseDateObj, to: expiryDate).day ?? 0
                totalDays += Double(daysDifference)
                validItems += 1
            } else if let expiryDate = dateFormatter.date(from: inventory.inventory_best_before_date) {
                // Use default expiration days from product if no purchase date
                let expirationDays = inventory.products.product_expiration_in_days ?? 7
                totalDays += Double(expirationDays)
                validItems += 1
            }
        }
        
        return validItems > 0 ? totalDays / Double(validItems) : 0.0
    }
    
    private func generateMonthlyStats(inventories: [HouseInventoryModelWithProducts], year: Int) -> [MonthlyStats] {
        let calendar = Calendar.current
        let monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                         "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        
        // Group inventories by month
        let monthlyInventories = Dictionary(grouping: inventories) { inventory in
            let createdAt = ISO8601DateFormatter().date(from: inventory.created_at) ?? Date()
            return calendar.component(.month, from: createdAt)
        }
        
        return monthNames.enumerated().map { index, month in
            let monthNumber = index + 1
            let monthInventories = monthlyInventories[monthNumber] ?? []
            
            let itemsSaved = calculateItemsSaved(inventories: monthInventories)
            let moneySaved = calculateMoneySaved(inventories: monthInventories)
            
            return MonthlyStats(month: month, itemsSaved: itemsSaved, moneySaved: moneySaved)
        }
    }
    
    private func extractTopCategories(inventories: [HouseInventoryModelWithProducts]) -> [String] {
        // Since we don't have categories in the database, let's categorize by common food types
        let foodCategories = [
            "Vegetables": ["tomato", "onion", "garlic", "carrot", "potato", "lettuce", "spinach", "pepper", "cucumber"],
            "Fruits": ["apple", "banana", "orange", "berry", "grape", "lemon", "lime", "avocado"],
            "Dairy": ["milk", "cheese", "yogurt", "butter", "cream"],
            "Meat": ["chicken", "beef", "pork", "fish", "salmon", "turkey"],
            "Grains": ["bread", "pasta", "rice", "cereal", "flour"]
        ]
        
        var categoryCounts: [String: Int] = [:]
        
        for inventory in inventories {
            let productName = inventory.products.product_name.lowercased()
            
            for (category, keywords) in foodCategories {
                if keywords.contains(where: { productName.contains($0) }) {
                    categoryCounts[category, default: 0] += inventory.inventory_quantity
                    break
                }
            }
        }
        
        return categoryCounts.sorted(by: { $0.value > $1.value }).prefix(3).map { $0.key }
    }
    
    private func calculateZeroWasteWeeks(inventories: [HouseInventoryModelWithProducts], year: Int) -> Int {
        // Calculate weeks where all items added were likely used before expiring
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Group by week
        let weeklyInventories = Dictionary(grouping: inventories) { inventory in
            let createdAt = ISO8601DateFormatter().date(from: inventory.created_at) ?? Date()
            return calendar.component(.weekOfYear, from: createdAt)
        }
        
        var zeroWasteWeeks = 0
        let currentDate = Date()
        
        for (_, weekInventories) in weeklyInventories {
            var weekHadWaste = false
            
            for inventory in weekInventories {
                if let expiryDate = dateFormatter.date(from: inventory.inventory_best_before_date) {
                    // If expiry date passed and item is still in inventory, it's likely waste
                    // For simplicity, assume 90% usage rate for zero waste calculation
                    if expiryDate < currentDate {
                        // This is simplified - in a real app you'd track actual usage
                        let wasteChance = 0.1 // 10% waste chance
                        if Double.random(in: 0...1) < wasteChance {
                            weekHadWaste = true
                            break
                        }
                    }
                }
            }
            
            if !weekHadWaste && !weekInventories.isEmpty {
                zeroWasteWeeks += 1
            }
        }
        
        return zeroWasteWeeks
    }
    
    private func generateAchievements(totalItemsSaved: Int, moneySaved: Double, zeroWasteWeeks: Int, totalItemsTracked: Int) -> [Achievement] {
        var achievements: [Achievement] = []
        
        if totalItemsSaved >= 100 {
            achievements.append(Achievement(
                title: "Waste Warrior",
                description: "You saved 100+ items from spoiling!",
                icon: "shield.fill",
                unlockedAt: Date(),
                type: .wasteWarrior
            ))
        }
        
        if moneySaved >= 500 {
            achievements.append(Achievement(
                title: "Savings Star",
                description: "You saved over €500 this year!",
                icon: "star.fill",
                unlockedAt: Date(),
                type: .savingsStar
            ))
        } else if moneySaved >= 100 {
            achievements.append(Achievement(
                title: "Money Saver",
                description: "You saved over €100 this year!",
                icon: "dollarsign.circle.fill",
                unlockedAt: Date(),
                type: .savingsStar
            ))
        }
        
        if zeroWasteWeeks >= 12 {
            achievements.append(Achievement(
                title: "Streak Master",
                description: "12+ weeks of zero waste!",
                icon: "flame.fill",
                unlockedAt: Date(),
                type: .streakMaster
            ))
        } else if zeroWasteWeeks >= 4 {
            achievements.append(Achievement(
                title: "Consistent Saver",
                description: "4+ weeks of zero waste!",
                icon: "checkmark.circle.fill",
                unlockedAt: Date(),
                type: .streakMaster
            ))
        }
        
        if totalItemsTracked >= 200 {
            achievements.append(Achievement(
                title: "Inventory Master",
                description: "You tracked 200+ items this year!",
                icon: "list.clipboard.fill",
                unlockedAt: Date(),
                type: .categoryKing
            ))
        }
        
        return achievements
    }
    
    private func generateFunInsight(totalItemsSaved: Int, mostUsedIngredient: String, moneySaved: Double) -> String {
        if totalItemsSaved > 200 {
            return "You're a Food Saving Legend! 🌟 Your dedication saved \(totalItemsSaved) items from waste!"
        } else if totalItemsSaved > 100 {
            return "You're the \(mostUsedIngredient.capitalized) Champion! 🏆 You saved \(totalItemsSaved) items this year!"
        } else if totalItemsSaved > 50 {
            return "Food waste? Not on your watch! 👀 You saved \(totalItemsSaved) items!"
        } else if totalItemsSaved > 20 {
            return "You're building great habits! 💪 Keep tracking to save even more!"
        } else {
            return "You're just getting started—keep it up! 🌱 Every item saved makes a difference!"
        }
    }
} 