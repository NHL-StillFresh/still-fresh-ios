import SwiftUI
import Supabase

struct TestSearchView: View {
    // Accept viewModel from parent or create a new one if not provided
    @ObservedObject var viewModel: ProductSearchViewModel
    @State private var selectedProduct: JumboProduct?
    @Environment(\.presentationMode) var presentationMode
    @State private var showSuccessAlert = false
    
    // For authentication with Supabase
    private let authEmail = "elmedin@test.nl"
    private let authPassword = "elmedin123"
    
    var body: some View {
        VStack(spacing: 16) {
            
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
            .overlay(Group {
                if viewModel.searchResults.isEmpty {
                    Text("No products found")
                        .foregroundColor(.gray)
                }
            })
            
            if let selected = selectedProduct {
                VStack(spacing: 12) {
                    Button("Add to inventory") {
                        Task {
                            do {
                                // Try to authenticate first
                                do {
                                    _ = try await SupaClient.auth.signIn(email: authEmail, password: authPassword)
                                } catch {
                                    print("Authentication error: \(error.localizedDescription)")
                                }
                                
                                let productData: [String: String] = [
                                    "product_name": selected.title,
                                    "product_image": selected.imageUrl ?? ""
                                ]
                                
                                try await SupaClient
                                    .from("products")
                                    .insert(productData)
                                    .execute()
                                
                                print("Successfully added product to Supabase")
                                
                                // Show success alert and dismiss after delay
                                await MainActor.run {
                                    showSuccessAlert = true
                                    // Dismiss after a short delay
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        self.presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            } catch {
                                print("Error adding to Supabase: \(error.localizedDescription)")
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(.horizontal)
            }
        }
        .alert("Product Added", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Product was successfully added to database")
        }
    }
    
    // Function to search products based on query
    func searchProducts(query: String) {
        viewModel.searchQuery = query
        Task {
            await viewModel.searchProducts()
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
                        .foregroundColor(.green)
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
}
#Preview {
    TestSearchView(viewModel: ProductSearchViewModel())
}
