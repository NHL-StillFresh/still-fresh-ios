//
//  ExpiryDateGuessModel.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 02/06/2025.
//
import SwiftUI

class ExpiryDateGuessModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    @Published var expiryDate: String? = nil
    
    private let productName: String
    private let apiKey: String = APIKeys.openRouterAPIKey
    
    init(productName: String) {
        print("Expiry model")
        self.productName = productName
        self.isLoading = true
        Task {
            await fetchExpiryDateFromAPI()
        }
    }
    
    private func fetchExpiryDateFromAPI() async {
        guard let request = AIHandler.buildOpenRouterRequest(apiKey: apiKey, messages: AIHandler.createExpiryDatePrompt(productName: self.productName)) else {
            self.error = "Invalid API request"
            self.isLoading = false
            return
        }
        
        print(request)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)

            guard let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = jsonResponse["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                self.error = "Invalid response format"
                return
            }

            self.expiryDate = content
        } catch {
            self.error = "Error fetching data: \(error.localizedDescription)"
        }

        self.isLoading = false
    }
}
