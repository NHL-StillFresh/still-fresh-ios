import Foundation
import SwiftUI

@MainActor
class ProductSearchViewModel: ObservableObject {
    @Published var searchQuery = ""
    @Published var searchResults: [JumboProduct] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let jumboService = JumboService()
    
    func searchProducts() async {
        print("Starting search with query: \(searchQuery)")
        guard !searchQuery.isEmpty else {
            print("Empty query, clearing results")
            searchResults = []
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            print("Fetching products from Jumbo API...")
            let response = try await jumboService.searchProducts(query: searchQuery)
            searchResults = response.products.data.filter { $0.available }
            print("Found \(searchResults.count) available products")
        } catch {
            print("Search error: \(error)")
            self.error = "Failed to search products: \(error.localizedDescription)"
            searchResults = []
        }
        
        isLoading = false
    }
}
