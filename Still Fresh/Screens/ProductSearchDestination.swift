import SwiftUI

struct ProductSearchDestination: View {
    let productName: String
    @State private var hasInitiatedSearch = false
    @StateObject private var viewModel = ProductSearchViewModel()
    
    var body: some View {
        TestSearchView(viewModel: viewModel)
            .onAppear {
                if !hasInitiatedSearch {
                    // Trigger search with the product name
                    viewModel.searchQuery = productName
                    Task {
                        await viewModel.searchProducts()
                    }
                    hasInitiatedSearch = true
                }
            }
    }
}
