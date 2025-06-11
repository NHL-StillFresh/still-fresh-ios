import Foundation

struct FoodSavingTip: Identifiable, Codable {
    let id: UUID
    let content: String
    
    init(id: UUID = UUID(), content: String) {
        self.id = id
        self.content = content
    }
}

struct DailyTips: Codable {
    let date: Date
    let tips: [FoodSavingTip]
    
    static var empty: DailyTips {
        DailyTips(date: Date(), tips: [])
    }
} 