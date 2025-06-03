//
//  AddProductManuallyView.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 03/06/2025.
//

import SwiftUI

struct AddProductManuallyView: View {
    @State private var searchText: String = ""
    @State private var isSearching: Bool = false
    @State private var searchResults: [FoodItem] = []
    @State private var showAddView = false
    @State private var sheetHeight : PresentationDetent = .height(320)
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Search your product")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 12)
            
            SearchBarView(
                searchText: $searchText,
                isSearching: $isSearching
            )
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 8)
            
            if searchText.isEmpty && !isSearching {
                defaultContent
            } else {
                searchResultsContent
            }
        }
        .padding(.top, 24)
        .onChange(of: searchText) { _, newValue in
            if !newValue.isEmpty {
                Task {
                    searchResults = await searchProducts(query: newValue)
                }
            }
        }
    }
    
    private var defaultContent: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 24) {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("Your results will show here")
                        .font(.title3)
                        .fontWeight(.medium)
                }
                Spacer(minLength: 80)
            }
            .padding(.top, 16)
        }
    }
    
    private var searchResultsContent: some View {
        VStack(spacing: 0) {
            if searchResults.isEmpty {
                VStack(spacing: 24) {
                    Spacer()
                    
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("No items found")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    Text("Try another search term or add a new external item")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Button(action: {
                        showAddView = true
                    }) {
                        Text("Add Food Item")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color(red: 0.04, green: 0.29, blue: 0.29))
                            .cornerRadius(12)
                    }
                    .padding(.top, 8)
                    .sheet(isPresented: $showAddView) {
                        AddView()
                            .presentationDetents([sheetHeight], selection: $sheetHeight)
                            .interactiveDismissDisabled(false)
                            .presentationDragIndicator(.visible)
                            .presentationCornerRadius(24)
                            .presentationCompactAdaptation(.none)
                    }
                    
                    Spacer()
                }
                .padding()
            } else {
                // List of search results
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(searchResults) { item in
                            SearchResultItemView(item: item)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
            }
        }
    }
    
    private func searchProducts(query: String) async -> [FoodItem]
    {
        var productsToReturn: [FoodItem] = []
        
        do {
            let products: [ProductModel] = try await SupaClient
                .from("products")
                .select()
                .ilike("product_name", pattern: "%\(query)%")
                .limit(15)
                .execute()
                .value
            
            productsToReturn = products.map { product in
                let expiryDate = Calendar.current.date(
                    byAdding: .day,
                    value: product.product_expiration_in_days ?? 0,
                    to: Calendar.current.startOfDay(for: Date())
                ) ?? Calendar.current.startOfDay(for: Date())
                
                return FoodItem(
                    id: UUID(),
                    name: product.product_name,
                    store: product.source_id?.rawValue ?? "Unknown",
                    image: product.product_image ?? "chicken",
                    expiryDate: expiryDate
                )
            }
            
        } catch {
            print ("Error searching products: \(error.localizedDescription)")
        }
        
        return productsToReturn
    }
    
}



#Preview {
    AddProductManuallyView()
}

