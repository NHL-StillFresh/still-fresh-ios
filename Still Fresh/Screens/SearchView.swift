import SwiftUI

struct SearchView: View {
    @AppStorage("recentSearches") private var recentSearchesData: String = "[]"
    
    private func getRecentSearches() -> [String] {
          if let data = recentSearchesData.data(using: .utf8),
             let decoded = try? JSONDecoder().decode([String].self, from: data) {
              return decoded
          }
          return []
      }

      private func setRecentSearches(_ newValue: [String]) {
          if let data = try? JSONEncoder().encode(newValue),
             let jsonString = String(data: data, encoding: .utf8) {
              recentSearchesData = jsonString
          }
      }
    
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var selectedCategory: FoodCategory? = nil
    @State private var showFilterSheet = false
    @State private var filters = SearchFilters()

    @State private var searchResults: [FoodItem] = []
    
    // Demo data for recently added items
    @State private var recentlyAddedItems = FoodItem.sampleItems
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                SearchBarView(
                    searchText: $searchText, 
                    isSearching: $isSearching,
                    onFilterTap: { showFilterSheet = true }
                )
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 8)
                
                if searchText.isEmpty && !isSearching {
                    // Default content when not searching
                    defaultContent
                } else {
                    // Search results
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
            VStack(alignment: .leading, spacing: 24) {
                // Categories section
                categoriesSection
                
                // Recent searches section
                if !getRecentSearches().isEmpty {
                    recentSearchesSection
                }
                
                // Recently added items
                if !recentlyAddedItems.isEmpty {
                    recentlyAddedSection
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
                                searchResults = simulateSearch(category: category)
                                isSearching = true
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    private var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Searches")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { setRecentSearches([]) }) {
                    Text("Clear")
                        .font(.subheadline)
                        .foregroundColor(Color(UIColor.systemTeal))
                }
            }
            .padding(.horizontal, 16)
            
            VStack(spacing: 0) {
                var recentSearches = getRecentSearches()
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
    
    private var recentlyAddedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recently Added")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    // View all action
                }) {
                    Text("View All")
                        .font(.subheadline)
                        .foregroundColor(Color(UIColor.systemTeal))
                }
            }
            .padding(.horizontal, 16)
            
            LazyVStack(spacing: 12) {
                ForEach(recentlyAddedItems) { item in
                    SearchResultItemView(item: item)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private var searchResultsContent: some View {
        VStack(spacing: 0) {
            if searchResults.isEmpty {
                // Empty search results
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
                        // Action to add items
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
                        store: product.source_id ?? "Unknown",
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
            case .produce:
                return sampleItems.filter { $0.name.lowercased().contains("spinach") }
            case .meat:
                return sampleItems.filter { $0.name.lowercased().contains("chicken") }
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
    var onFilterTap: () -> Void
    
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
            } else {
                Button(action: onFilterTap) {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(Color(UIColor.systemTeal))
                        .padding(.leading, 8)
                }
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

// Search Result Item View
struct SearchResultItemView: View {
    let item: FoodItem
    
    var body: some View {
        HStack(spacing: 16) {
            // Food icon with background
            ZStack {
                Circle()
                    .fill(bgColorForItem)
                    .frame(width: 60, height: 60)
                
                Image(systemName: symbolNameForItem)
                    .font(.system(size: 26))
                    .foregroundColor(bgColorForItem.opacity(1.5))
            }
            
            // Item details
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.system(size: 17, weight: .medium))
                
                Text(item.store)
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                
                // Expiry indicator
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(expiryColor)
                        .font(.system(size: 12))
                    
                    Text(item.expiryText)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(expiryColor)
                }
            }
            
            Spacer()
            
            // Add to basket button
            Button(action: {
                // Add to basket functionality
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 26))
                    .foregroundColor(Color(UIColor.systemTeal))
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // Background color based on the item
    private var bgColorForItem: Color {
        switch item.name.lowercased() {
        case let name where name.contains("milk") || name.contains("yogurt"):
            return Color.blue.opacity(0.2)
        case let name where name.contains("chicken"):
            return Color.orange.opacity(0.2)
        case let name where name.contains("spinach") || name.contains("veggie"):
            return Color.green.opacity(0.2)
        default:
            return Color(red: 122/255, green: 190/255, blue: 203/255).opacity(0.2)
        }
    }
    
    // Symbol based on food type
    private var symbolNameForItem: String {
        switch item.name.lowercased() {
        case let name where name.contains("milk"):
            return "drop.fill"
        case let name where name.contains("chicken"):
            return "bird.fill"
        case let name where name.contains("spinach") || name.contains("veggie"):
            return "leaf.fill"
        case let name where name.contains("yogurt"):
            return "cup.and.saucer.fill"
        default:
            return "fork.knife"
        }
    }
    
    // Color based on days until expiry
    private var expiryColor: Color {
        if item.daysUntilExpiry == 0 {
            return .red
        } else if item.daysUntilExpiry <= 2 {
            return .orange
        } else {
            return Color(red: 122/255, green: 190/255, blue: 203/255)
        }
    }
}

// Food Categories
enum FoodCategory: String, CaseIterable {
    case dairy = "Dairy"
    case produce = "Produce"
    case meat = "Meat"
    case bakery = "Bakery"
    case frozen = "Frozen"
    case pantry = "Pantry"
    
    var name: String {
        return self.rawValue
    }
    
    var iconName: String {
        switch self {
        case .dairy: return "cup.and.saucer.fill"
        case .produce: return "leaf.fill"
        case .meat: return "fork.knife"
        case .bakery: return "birthday.cake.fill"
        case .frozen: return "snow"
        case .pantry: return "cabinet.fill"
        }
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
