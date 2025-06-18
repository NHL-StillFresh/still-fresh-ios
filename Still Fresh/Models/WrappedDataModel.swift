import Foundation

struct WrappedData: Codable {
    let year: Int
    let totalItemsSaved: Int
    let moneySaved: Double
    let mostUsedIngredient: String
    let mostUsedIngredientCount: Int
    let favoriteRecipe: String
    let zeroWasteWeeks: Int
    let totalItemsTracked: Int
    let avgDaysUntilExpiry: Double
    let topCategories: [String]
    let monthlyStats: [MonthlyStats]
    let achievements: [Achievement]
    let funInsight: String
    let generatedAt: Date
    
    static var empty: WrappedData {
        WrappedData(
            year: Calendar.current.component(.year, from: Date()),
            totalItemsSaved: 0,
            moneySaved: 0.0,
            mostUsedIngredient: "Unknown",
            mostUsedIngredientCount: 0,
            favoriteRecipe: "None yet",
            zeroWasteWeeks: 0,
            totalItemsTracked: 0,
            avgDaysUntilExpiry: 0.0,
            topCategories: [],
            monthlyStats: [],
            achievements: [],
            funInsight: "Keep tracking to unlock insights! 🌱",
            generatedAt: Date()
        )
    }
}

struct MonthlyStats: Codable {
    let month: String
    let itemsSaved: Int
    let moneySaved: Double
}

struct Achievement: Codable, Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let unlockedAt: Date
    let type: AchievementType
    
    enum AchievementType: String, Codable, CaseIterable {
        case wasteWarrior = "waste_warrior"
        case savingsStar = "savings_star"
        case streakMaster = "streak_master"
        case categoryKing = "category_king"
        case earlyBird = "early_bird"
    }
} 