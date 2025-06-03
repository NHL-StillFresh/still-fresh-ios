//
//  ExpiryDateGuessModel.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 02/06/2025.
//
import SwiftUI

class ExpiryDateGuessModel: ObservableObject {
    private let apiKey: String = APIKeys.openRouterAPIKey
    
    public func fetchExpiryDateFromAPI(productName: String) async -> Int? {
        guard let request = AIHandler.buildOpenRouterRequest(apiKey: apiKey, messages: AIHandler.createExpiryDatePrompt(productName: productName)) else {
            print("Invalid API request")
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)

            guard let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = jsonResponse["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                print("Invalid response format")
                return nil
            }

            return Int(content)
        } catch {
            return nil
        }
    }
}
