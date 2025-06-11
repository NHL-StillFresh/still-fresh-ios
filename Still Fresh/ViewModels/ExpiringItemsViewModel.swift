import Foundation
import SwiftUI
import Combine

class ExpiringItemsViewModel: ObservableObject {
    @Published var expiringItems: [FoodItem] = []
    
    init() {
        // For demonstration purposes, load sample data
        // In a real app, this would fetch from a database or API
        loadSampleItems()
    }
    
    private func loadSampleItems() {
        // Using sample items from FoodItem extension for demo
        expiringItems = FoodItem.sampleItems
            .sorted(by: { $0.daysUntilExpiry < $1.daysUntilExpiry })
    }
    
    func navigateToItemDetails(item: FoodItem) {
        // In a real app, this would handle navigation to item details
        print("Navigating to details for \(item.name)")
    }
    
    func seeAllItems() {
        // In a real app, this would navigate to a full list view
        print("Navigating to all expiring items")
    }
} 