import Foundation
import SwiftUI
import Combine

class RecipesViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    @AppStorage("recipeLastUpdatedDate") private var lastUpdated: Date?
    
    private let apiKey: String = APIKeys.openRouterAPIKey

    private let userDefaults = UserDefaults.standard
    private let recipeCacheKey = "cachedRecipes"

    init() {
        loadCachedRecipes()
        
        if shouldGenerateNewTips() {
            generateRecipe()
        }
    }
    
    private func shouldGenerateNewTips() -> Bool {
        let calendar = Calendar.current
        return recipes.isEmpty || lastUpdated == nil || !calendar.isDateInToday(lastUpdated!)
    }
     
    func generateRecipe() {
        guard !isLoading else { return }
        
        Task {
            do {
                await fetchRecipeFromAPI(products: try await BasketHandler.getBasketProducts())
            } catch {
                print("Error fetching recipe: \(error)")
            }
        }
        
    }
    
    func fetchRecipeFromAPI(products: [FoodItem]) async {
        await MainActor.run { self.isLoading = true }
        self.error = nil

        let messages = AIHandler.createRecipePrompt(products: products)

        guard let request = AIHandler.buildOpenRouterRequest(apiKey: apiKey, messages: messages) else {
            await MainActor.run {
                self.error = "Invalid API request"
                self.isLoading = false
            }
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(for: request)

            guard let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = jsonResponse["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                await MainActor.run {
                    self.error = "Invalid response format"
                    self.isLoading = false
                }
                return
            }

            // Decode an array of CodableRecipe from content string
            if let contentData = content.data(using: .utf8),
               let decodedArray = try? JSONDecoder().decode([CodableRecipe].self, from: contentData) {

                let mappedRecipes = decodedArray.map { $0.toRecipe() }

                await MainActor.run {
                    self.recipes = mappedRecipes
                    self.lastUpdated = Date()
                    self.cacheRecipes()
                }

            } else {
                await MainActor.run {
                    self.error = "Failed to decode recipes array"
                }
            }

        } catch {
            await MainActor.run {
                self.error = "Error fetching data: \(error.localizedDescription)"
            }
        }

        await MainActor.run {
            self.isLoading = false
        }
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
}
