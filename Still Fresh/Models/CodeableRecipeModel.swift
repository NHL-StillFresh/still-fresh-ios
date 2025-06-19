//
//  CodeableRecipeModel.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 13/06/2025.
//

struct CodableRecipe: Codable {
    let name: String
    let description: String
    let cookingSteps: String
    let cookingTime: Int
    let difficulty: String
    let ingredients: [String]
    
    func toRecipe() -> Recipe {
        return Recipe(
            name: name,
            description: description,
            cookingSteps: cookingSteps,
            cookingTime: cookingTime,
            difficulty: RecipeDifficulty(rawValue: difficulty.lowercased()) ?? .easy,
            ingredients: ingredients,
            imageName: "fork.knife",
            tags: []
        )
    }
    
    init(from recipe: Recipe) {
        self.name = recipe.name
        self.description = recipe.description
        self.cookingSteps = recipe.cookingSteps
        self.cookingTime = recipe.cookingTime
        self.difficulty = recipe.difficulty.rawValue
        self.ingredients = recipe.ingredients
    }
}
