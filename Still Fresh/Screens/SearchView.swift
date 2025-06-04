import SwiftUI

struct SearchView: View {
    @StateObject private var recentSearchesHandler = RecentSearchesHandler()
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var selectedCategory: FoodCategory? = nil
    @State private var showFilterSheet = false
    @State private var filters = SearchFilters()

    @State private var searchResults: [FoodItem] = []
    
    @State private var showAddView = false
    @State private var sheetHeight : PresentationDetent = .height(320)
    
    @State private var showErrorAlert = false
    @State private var showSuccesAlert = false
    @Environment(\.dismiss) private var dismiss
    
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                SearchBarView(
                    searchText: $searchText, 
                    isSearching: $isSearching,
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
            .navigationBarHidden(true)
            .sheet(isPresented: $showFilterSheet) {
                FilterSheetView(filters: $filters)
            }
            .onChange(of: searchText) { _, newValue in
                if !newValue.isEmpty {
                    Task {
                        searchResults = await searchProducts(query: newValue)
                    }
                }
            }
        }
    }
    
    private var defaultContent: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 24) {
                categoriesSection
                
                if !recentSearchesHandler.getRecentSearches().isEmpty {
                    recentSearchesSection
                } else {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "clock")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("No recent items")
                            .font(.title3)
                            .fontWeight(.medium)
                    }
                }
                
                Spacer(minLength: 80)
            }
            .padding(.top, 16)
        }
    }
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categories")
                .font(.headline)
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(FoodCategory.allCases, id: \.self) { category in
                        CategoryCard(
                            category: category,
                            isSelected: selectedCategory == category,
                            onTap: {
                                selectedCategory = category
                                // Simulate search for this category
                                Task {
                                    searchResults = await  searchProducts(category: category)
                                    isSearching = true
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .frame(height: 100)
            }
        }
    }
    
    private var recentSearchesSection: some View {
        let recentSearches = recentSearchesHandler.getRecentSearches()

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Searches")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { recentSearchesHandler.setRecentSearches([]);
                    
                }) {
                    Text("Clear")
                        .font(.subheadline)
                        .foregroundColor(Color(UIColor.systemTeal))
                }
            }
            .padding(.horizontal, 16)
            
            VStack(spacing: 0) {
                                
                ForEach(recentSearches, id: \.self) { search in
                    Button(action: {
                        searchText = search
                        isSearching = true
                    }) {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.gray)
                                .font(.system(size: 14))
                            
                            Text(search)
                                .font(.system(size: 16))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.left")
                                .foregroundColor(Color(UIColor.systemTeal))
                                .font(.system(size: 14))
                        }
                        .padding(.vertical, 12)
                    }
                    
                    if search != recentSearches.last {
                        Divider()
                            .padding(.leading, 30)
                    }
                }
            }
            .padding(.horizontal, 16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal, 16)
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
                    
                    Text("Try another search term or add a new item")
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
                            SearchResultItem(item: item, extraFunction: {
                                Task {
                                    if await SupabaseProductHandler.addAllSelectedProducts(selectedProducts: [:], knownProducts: [item.name]) {
                                        showSuccesAlert = true
                                    } else {
                                        showErrorAlert = true
                                    }
                                }
                            })
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
            }
        }
        .alert("Products succesfully added to your basket!", isPresented: $showSuccesAlert) {
            Button("Close") {
                dismiss()
            }
        }
        .alert("Error adding your products to your basket", isPresented: $showSuccesAlert) {
            Button("Close", role: .cancel) {}
        }
    }
    
    private func searchProducts(query: String? = nil , category: FoodCategory? = nil) async -> [FoodItem] {
        
        var productsToReturn: [FoodItem] = []
        
        do {
            
            if let query = query, !query.isEmpty {
                
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
                
            } else if let category = category {
                
            }
            
        } catch {
            print ("Error searching products: \(error)")
        }
        
        return productsToReturn
    }
    
    // Simulate search results based on query
    private func simulateSearch(query: String? = nil, category: FoodCategory? = nil) -> [FoodItem] {
        let sampleItems = FoodItem.sampleItems
        
        if let query = query, !query.isEmpty {
            return sampleItems.filter {
                $0.name.lowercased().contains(query.lowercased()) ||
                $0.store.lowercased().contains(query.lowercased())
            }
        } else if let category = category {
            // Filter by category (example implementation)
            switch category {
            case .dairy:
                return sampleItems.filter { $0.name.lowercased().contains("milk") || $0.name.lowercased().contains("yogurt") }
            
            default:
                return sampleItems
            }
        }
        
        return sampleItems
    }
}

// Search Bar component
struct SearchBarView: View {
    @Binding var searchText: String
    @Binding var isSearching: Bool
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search food items...", text: $searchText)
                    .font(.system(size: 16))
                    .onTapGesture {
                        isSearching = true
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            if isSearching {
                Button(action: {
                    searchText = ""
                    isSearching = false
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }) {
                    Text("Cancel")
                        .foregroundColor(Color(UIColor.systemTeal))
                }
                .padding(.leading, 8)
                .transition(.move(edge: .trailing))
                .animation(.default, value: isSearching)
            }
        }
    }
}

// Filter Sheet
struct FilterSheetView: View {
    @Binding var filters: SearchFilters
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Expiry Date")) {
                    Toggle("Expiring Soon", isOn: $filters.expiringOnly)
                    
                    if !filters.expiringOnly {
                        DatePicker("From", selection: $filters.dateFrom, displayedComponents: .date)
                        DatePicker("To", selection: $filters.dateTo, displayedComponents: .date)
                    }
                }
                
                Section(header: Text("Categories")) {
                    ForEach(FoodCategory.allCases, id: \.self) { category in
                        Button(action: {
                            if filters.categories.contains(category) {
                                filters.categories.remove(category)
                            } else {
                                filters.categories.insert(category)
                            }
                        }) {
                            HStack {
                                Text(category.name)
                                Spacer()
                                if filters.categories.contains(category) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color(UIColor.systemTeal))
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
                
                Section(header: Text("Stores")) {
                    ForEach(["Albert Heijn", "Jumbo", "Aldi", "Lidl"], id: \.self) { store in
                        Button(action: {
                            if filters.stores.contains(store) {
                                filters.stores.remove(store)
                            } else {
                                filters.stores.insert(store)
                            }
                        }) {
                            HStack {
                                Text(store)
                                Spacer()
                                if filters.stores.contains(store) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color(UIColor.systemTeal))
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
            .navigationTitle("Search Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        filters = SearchFilters()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}

// Food Category Component
struct CategoryCard: View {
    let category: FoodCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isSelected ? Color(red: 0.04, green: 0.29, blue: 0.29) : Color(UIColor.systemGray6))
                    .frame(width: 70, height: 70)
                
                Image(systemName: category.iconName)
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? .white : Color(UIColor.systemTeal))
            }
            
            Text(category.name)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? Color(red: 0.04, green: 0.29, blue: 0.29) : .primary)
                .multilineTextAlignment(.center)
        }
        .frame(width: 90)
        .onTapGesture(perform: onTap)
    }
}

// Search Filters
struct SearchFilters {
    var expiringOnly: Bool = false
    var dateFrom: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    var dateTo: Date = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
    var categories: Set<FoodCategory> = []
    var stores: Set<String> = []
}

#Preview {
    SearchView()
}
