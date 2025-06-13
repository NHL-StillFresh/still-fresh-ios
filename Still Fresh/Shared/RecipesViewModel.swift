import Foundation
import SwiftUI
import Combine

class RecipesViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    
    private let apiKey: String = APIKeys.openRouterAPIKey

    private let userDefaults = UserDefaults.standard
    private let recipeCacheKey = "cachedRecipes"

    init() {
        generateRecipe()
    }
    
    func generateRecipe() {
        guard !isLoading else { return }
        
        
        Task {
            await fetchRecipeFromAPI(products: try! await BasketHandler.getBasketProducts())
        }
        
    }
    
    func fetchRecipeFromAPI(products: [FoodItem]) async {
        let messages = AIHandler.createRecipePrompt(products: products)

        guard let request = AIHandler.buildOpenRouterRequest(apiKey: apiKey, messages: messages) else {
            self.error = "Invalid API request"
            self.isLoading = false
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(for: request)

            guard let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = jsonResponse["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                self.error = "Invalid response format"
                self.isLoading = false
                return
            }

            // Decode an array of CodableRecipe from content string
            if let data = content.data(using: .utf8),
               let decodedArray = try? JSONDecoder().decode([CodableRecipe].self, from: data) {
                
                // Convert [CodableRecipe] to [Recipe]
                let recipes = decodedArray.map { $0.toRecipe() }
                self.recipes = recipes
                cacheRecipes()

            } else {
                self.error = "Failed to decode recipes array"
            }

        } catch {
            self.error = "Error fetching data: \(error.localizedDescription)"
        }

        self.isLoading = false
    }

    private func loadCachedRecipes() {
        if let data = userDefaults.data(forKey: recipeCacheKey),
           let decoded = try? JSONDecoder().decode([CodableRecipe].self, from: data) {
            self.recipes = decoded.map { $0.toRecipe() }
        }
    }

    private func cacheRecipes() {
        let codableRecipes = recipes.map { CodableRecipe(from: $0) }
        if let data = try? JSONEncoder().encode(codableRecipes) {
            userDefaults.set(data, forKey: recipeCacheKey)
        }
    }

    func loadDefaultRecipes() {
        self.recipes = Recipe.sampleRecipes
        cacheRecipes()
    }

    func refreshRecipes() {
        // Replace with actual logic for fetching from API if needed
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.loadDefaultRecipes()
            self.isLoading = false
        }
    }
}
