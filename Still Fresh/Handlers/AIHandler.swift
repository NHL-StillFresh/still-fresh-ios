//
//  AIHandler.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 02/06/2025.
//

import Foundation

class AIHandler {
    static let openRouterEndpoint = "https://openrouter.ai/api/v1/chat/completions"
    static let modelName = "mistralai/mistral-small-3.1-24b-instruct:free"
    
    static func createFoodTipsPrompt() -> [[String: Any]] {
        let prompt = """
        You are a helpful assistant that gives short, practical food-saving tips.

        Generate 6 different, simple, and creative food-saving tips. Each tip should be no more than 10 words. Tips must help people prevent food from going bad or expiring too soon.

        Respond with just the 6 tips, numbered, each on a new line. Do not add extra commentary.

        Example:  
        1. Store onions in a cool, dry, ventilated space.  
        2. Keep herbs fresh in a jar with water.  
        3. Freeze leftover fruit for smoothies or baking.  

        Now generate today's 6 tips.
        """
        
        return [
            ["role": "system", "content": "You are a helpful assistant."],
            ["role": "user", "content": prompt]
        ]
    }
    
    static func createExpiryDatePrompt(productName: String) -> [[String: Any]] {
        let prompt = """
        You are an expert in supermarket food safety and storage. 

        Guess a realistic number of expiry days for the product "\(productName)", assuming it is bought fresh from a typical supermarket and stored properly in a home fridge or pantry.

        Only respond with the number of days as an integer. Do not include units like "days" or any extra text.

        If the product can vary (e.g., "meat"), choose the most common type (e.g., minced beef).
        """

        return [
            ["role": "user", "content": prompt]
        ]
    }
    
    static func createRecipePrompt(products: [FoodItem]) -> [[String: Any]] {
        let productList = products.map { $0.name }.joined(separator: ", ")

        let prompt = """
        You are a creative and helpful assistant.

        Based on the following ingredients:
        \(productList)

        Suggest **5 different** creative recipes using mostly these ingredients. For each recipe, include:
        - A name for the recipe
        - A short description
        - A cooking time in minutes (max 60)
        - A difficulty level (easy, medium, hard)
        - A list of ingredients
        - A detailed list of numbered cooking steps

        Respond **only** in JSON with an array of recipes in the following format:
        [
          {
            "name": "...",
            "description": "...",
            "cookingTime": 20,
            "difficulty": "easy",
            "ingredients": ["...", "..."],
            "cookingSteps": "1. ...\\n2. ...\\n3. ..."
          },
          {
            "name": "...",
            "description": "...",
            "cookingTime": 30,
            "difficulty": "medium",
            "ingredients": ["...", "..."],
            "cookingSteps": "1. ...\\n2. ...\\n3. ..."
          },
          {
            "name": "...",
            "description": "...",
            "cookingTime": 45,
            "difficulty": "hard",
            "ingredients": ["...", "..."],
            "cookingSteps": "1. ...\\n2. ...\\n3. ..."
          }
        ]
        """

        return [
            ["role": "system", "content": "You are a helpful assistant that creates recipes based on given ingredients."],
            ["role": "user", "content": prompt]
        ]
    }


    
    static func buildOpenRouterRequest(apiKey: String, messages: [[String: Any]]) -> URLRequest? {
        guard let url = URL(string: openRouterEndpoint) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("still-fresh-ios", forHTTPHeaderField: "HTTP-Referer")
        request.addValue("https://stillfresh.app", forHTTPHeaderField: "OpenRouter-Referrer")
        request.addValue("StillFresh iOS App", forHTTPHeaderField: "User-Agent")
        
        let body: [String: Any] = [
            "model": modelName,
            "messages": messages,
            "max_tokens": 200,
            "temperature": 0.7,
            "top_p": 1,
            "stream": false
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            return request
        } catch {
            print("Error building request body: \(error)")
            return nil
        }
    }
}
