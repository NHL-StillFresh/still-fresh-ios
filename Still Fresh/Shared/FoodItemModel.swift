import Foundation

struct FoodItem: Identifiable {
    let id: UUID
    let house_inventory_id: Int? // Added for database deletion
    let name: String
    let store: String
    let image: String? // Image name
    let expiryDate: Date
    
    init(id: UUID = UUID(), house_inventory_id: Int? = nil, name: String, store: String, image: String?, expiryDate: Date) {
        self.id = id
        self.house_inventory_id = house_inventory_id
        self.name = name
        self.store = store
        self.image = image
        self.expiryDate = expiryDate
    }
    
    var daysUntilExpiry: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let expiry = calendar.startOfDay(for: expiryDate)
        
        if let days = calendar.dateComponents([.day], from: today, to: expiry).day {
            return max(0, days)
        }
        return 0
    }
    
    var expiryText: String {
        if daysUntilExpiry == 0 {
            return "Expires today"
        } else if daysUntilExpiry == 1 {
            return "Expires tomorrow"
        } else {
            return "Expires in \(daysUntilExpiry) days"
        }
    }
}

// Sample data for preview
extension FoodItem {
    static var sampleItems: [FoodItem] {
        let calendar = Calendar.current
        let today = Date()
        
        return [
            FoodItem(
                name: "Organic Milk",
                store: "Albert Heijn",
                image: "milk",
                expiryDate: calendar.date(byAdding: .day, value: 2, to: today)!
            ),
            FoodItem(
                name: "Chicken Breast",
                store: "Jumbo",
                image: "chicken",
                expiryDate: calendar.date(byAdding: .day, value: 1, to: today)!
            ),
            FoodItem(
                name: "Fresh Spinach",
                store: "Aldi",
                image: "spinach",
                expiryDate: calendar.date(byAdding: .day, value: 3, to: today)!
            ),
            FoodItem(
                name: "Yogurt",
                store: "Albert Heijn",
                image: "yogurt",
                expiryDate: today
            )
        ]
    }
} 
