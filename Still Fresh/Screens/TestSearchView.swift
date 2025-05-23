import SwiftUI

struct TestSearchView: View {
    @StateObject private var viewModel = ProductSearchViewModel()
    @State private var selectedProduct: JumboProduct?
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 16) {
            // Search Bar
            HStack {
                TextField("Search products...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: {
                    viewModel.searchQuery = searchText
                    Task {
                        print("Search button tapped with query: \(searchText)")
                        await viewModel.searchProducts()
                    }
                }) {
                    Text("Search")
                }
                .buttonStyle(.borderedProminent)
                .padding(.trailing)
                .disabled(searchText.isEmpty)
            }
            
            // Results List
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.searchResults) { product in
                        ProductTestCard(
                            product: product,
                            isSelected: selectedProduct?.id == product.id
                        )
                        .onTapGesture {
                            if selectedProduct?.id == product.id {
                                selectedProduct = nil
                            } else {
                                selectedProduct = product
                            }
                        }
                    }
                }
                .padding()
            }
            
            if let selected = selectedProduct {
                VStack(spacing: 12) {
                    Button("Preview Selected Data") {
                        print("\nSelected Product Data:")
                        print("------------------------")
                        print("ID: \(selected.id)")
                        print("Title: \(selected.title)")
                        print("Price: \(selected.displayPrice)")
                        print("Image URL: \(selected.imageUrl ?? "No image")")
                        if let quantity = selected.quantity {
                            print("Quantity: \(quantity)")
                        }
                        print("------------------------\n")
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Button("Add \(selected.title) to Supabase") {
                        // TODO: Add Supabase integration
                        print("Preparing data for Supabase:")
                        let dataToStore = [
                            "id": selected.id,
                            "title": selected.title,
                            "price": selected.prices.price.amount / 100,
                            "image_url": selected.imageUrl as Any,
                            "quantity": selected.quantity as Any
                        ]
                        print(dataToStore)
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
    }
}

struct ProductTestCard: View {
    let product: JumboProduct
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Product Image
            if let imageUrl = product.imageUrl {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 80, height: 80)
                .cornerRadius(8)
            } else {
                Color.gray.opacity(0.3)
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(product.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text("Price: \(product.displayPrice)")
                    .font(.subheadline)
                
                Text("Protein: N/A")
                    .font(.caption)
                
                Text("Calories: N/A")
                    .font(.caption)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
    TestSearchView()
}
