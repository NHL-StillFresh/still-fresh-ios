import Foundation
import SwiftUI

struct Recipe: Identifiable {
    let id: UUID
    let name: String
    let description: String
    let cookingTime: Int // in minutes
    let difficulty: RecipeDifficulty
    let ingredients: [String]
    let imageName: String
    let tags: [String]
    
    init(id: UUID = UUID(), name: String, description: String, cookingTime: Int, 
         difficulty: RecipeDifficulty, ingredients: [String], imageName: String, tags: [String]) {
        self.id = id
        self.name = name
        self.description = description
        self.cookingTime = cookingTime
        self.difficulty = difficulty
        self.ingredients = ingredients
        self.imageName = imageName
        self.tags = tags
    }
    
    var cookingTimeText: String {
        if cookingTime < 60 {
            return "\(cookingTime) min"
        } else {
            let hours = cookingTime / 60
            let minutes = cookingTime % 60
            
            if minutes == 0 {
                return "\(hours) hr"
            } else {
                return "\(hours) hr \(minutes) min"
            }
        }
    }
}

enum RecipeDifficulty: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var color: Color {
        switch self {
        case .easy:
            return Color.green
        case .medium:
            return Color.orange
        case .hard:
            return Color.red
        }
    }
}

// Sample data for preview
extension Recipe {
    static var sampleRecipes: [Recipe] {
        return [
            Recipe(
                name: "15-min Pasta",
                description: "Quick pasta with leftover veggies and cheese",
                cookingTime: 15,
                difficulty: .easy,
                ingredients: ["Pasta", "Cheese", "Vegetables"],
                imageName: "pasta",
                tags: ["Quick", "Pasta"]
            ),
            Recipe(
                name: "Veggie Frittata",
                description: "Use up any vegetables in this simple egg dish",
                cookingTime: 20,
                difficulty: .easy,
                ingredients: ["Eggs", "Vegetables", "Herbs"],
                imageName: "frittata",
                tags: ["Eggs", "Vegetarian"]
            ),
            Recipe(
                name: "Leftover Fried Rice",
                description: "Transform yesterday's rice into a delicious meal",
                cookingTime: 15,
                difficulty: .easy,
                ingredients: ["Rice", "Vegetables", "Soy Sauce"],
                imageName: "fried-rice",
                tags: ["Rice", "Asian"]
            ),
            Recipe(
                name: "Cheese Quesadilla",
                description: "Simple quesadilla with cheese and any fillings",
                cookingTime: 10,
                difficulty: .easy,
                ingredients: ["Tortillas", "Cheese", "Vegetables"],
                imageName: "quesadilla",
                tags: ["Mexican", "Quick"]
            ),
            Recipe(
                name: "Smoothie Bowl",
                description: "Blend almost-too-ripe fruits into a delicious bowl",
                cookingTime: 5,
                difficulty: .easy,
                ingredients: ["Fruits", "Yogurt", "Honey"],
                imageName: "smoothie-bowl",
                tags: ["Breakfast", "Healthy"]
            )
        ]
    }
} 