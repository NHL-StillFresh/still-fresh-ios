import Foundation
import SwiftUI
import Combine

class RecipesViewModel: ObservableObject {
    @Published var lastMinuteRecipes: [Recipe] = []
    
    init() {
        // For demonstration purposes, load sample data
        // In a real app, this would fetch from a database or API
        loadSampleRecipes()
    }
    
    private func loadSampleRecipes() {
        // Load sample recipes and sort by cooking time (quickest first)
        lastMinuteRecipes = Recipe.sampleRecipes
            .sorted(by: { $0.cookingTime < $1.cookingTime })
    }
    
    func navigateToRecipeDetails(recipe: Recipe) {
        // In a real app, this would handle navigation to recipe details
        print("Navigating to details for \(recipe.name)")
    }
    
    func seeAllRecipes() {
        // In a real app, this would navigate to a full recipes list view
        print("Navigating to all last minute recipes")
    }
} 