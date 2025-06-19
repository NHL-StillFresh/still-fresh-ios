import Foundation
import SwiftUI

struct Recipe {
    let name: String
    let description: String
    let cookingSteps: String
    let cookingTime: Int // in minutes
    let difficulty: RecipeDifficulty
    let ingredients: [String]
    let imageName: String
    let tags: [String]
    
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
    
    var difficultyColor: Color {
        switch difficulty {
        case .easy:
            return Color.green
        case .medium:
            return Color.orange
        case .hard:
            return Color.red
        }
    }
}

enum RecipeDifficulty: String, Codable {
    case easy
    case medium
    case hard
}


// Sample data for preview
extension Recipe {
    static var sampleRecipes: [Recipe] {
        return [
            Recipe(
                name: "15-min Pasta",
                description: "Quick pasta with leftover veggies and cheese",
                cookingSteps: """
                1. Boil pasta until al dente.  
                2. Sauté leftover vegetables in a pan.  
                3. Add cooked pasta to the vegetables.  
                4. Stir in cheese until melted.  
                5. Season and serve warm.
                """,
                cookingTime: 15,
                difficulty: .easy,
                ingredients: ["Pasta", "Cheese", "Vegetables"],
                imageName: "pasta",
                tags: ["Quick", "Pasta"]
            ),
            Recipe(
                name: "Veggie Frittata",
                description: "Use up any vegetables in this simple egg dish",
                cookingSteps: """
                1. Preheat oven to 180°C (350°F).  
                2. Whisk eggs in a bowl with herbs.  
                3. Sauté chopped vegetables in a pan.  
                4. Pour eggs over vegetables and cook until edges set.  
                5. Transfer to oven and bake for 10 minutes.
                """,
                cookingTime: 20,
                difficulty: .easy,
                ingredients: ["Eggs", "Vegetables", "Herbs"],
                imageName: "frittata",
                tags: ["Eggs", "Vegetarian"]
            ),
            Recipe(
                name: "Leftover Fried Rice",
                description: "Transform yesterday's rice into a delicious meal",
                cookingSteps: """
                1. Heat oil in a wok or pan.  
                2. Add chopped vegetables and stir-fry.  
                3. Push veggies aside and scramble an egg if desired.  
                4. Add rice and soy sauce, stir everything together.  
                5. Cook until heated through and slightly crispy.
                """,
                cookingTime: 15,
                difficulty: .easy,
                ingredients: ["Rice", "Vegetables", "Soy Sauce"],
                imageName: "fried-rice",
                tags: ["Rice", "Asian"]
            ),
            Recipe(
                name: "Cheese Quesadilla",
                description: "Simple quesadilla with cheese and any fillings",
                cookingSteps: """
                1. Heat a pan over medium heat.  
                2. Place a tortilla in the pan.  
                3. Add cheese and leftover vegetables.  
                4. Top with another tortilla and cook until golden.  
                5. Flip, cook other side, then slice and serve.
                """,
                cookingTime: 10,
                difficulty: .easy,
                ingredients: ["Tortillas", "Cheese", "Vegetables"],
                imageName: "quesadilla",
                tags: ["Mexican", "Quick"]
            ),
            Recipe(
                name: "Smoothie Bowl",
                description: "Blend almost-too-ripe fruits into a delicious bowl",
                cookingSteps: """
                1. Add fruits and yogurt to a blender.  
                2. Blend until smooth and thick.  
                3. Pour into a bowl.  
                4. Drizzle with honey.  
                5. Top with granola or extra fruit if desired.
                """,
                cookingTime: 5,
                difficulty: .easy,
                ingredients: ["Fruits", "Yogurt", "Honey"],
                imageName: "smoothie-bowl",
                tags: ["Breakfast", "Healthy"]
            )
        ]
    }
}

