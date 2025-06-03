import SwiftUI

struct BasketView: View {
    @State private var foodItems: [FoodItem] = FoodItem.sampleItems
    @State private var showSortOptions = false
    @State private var sortOption: SortOption = .expiryDate
    @State private var searchText = ""
    @State private var isEditMode = false
    @State private var selectedItems = Set<UUID>()
    
    enum SortOption: String, CaseIterable {
        case expiryDate = "Expiry Date"
        case name = "Name"
        case store = "Store"
    }
    
    var sortedItems: [FoodItem] {
        let filteredItems = searchText.isEmpty ? foodItems : foodItems.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.store.localizedCaseInsensitiveContains(searchText)
        }
        
        switch sortOption {
        case .expiryDate:
            return filteredItems.sorted { $0.expiryDate < $1.expiryDate }
        case .name:
            return filteredItems.sorted { $0.name < $1.name }
        case .store:
            return filteredItems.sorted { $0.store < $1.store }
        }
    }
    
    var groupedItems: [String: [FoodItem]] {
        Dictionary(grouping: sortedItems) { item in
            if item.daysUntilExpiry == 0 {
                return "Today"
            } else if item.daysUntilExpiry == 1 {
                return "Tomorrow"
            } else if item.daysUntilExpiry <= 3 {
                return "Next Few Days"
            } else {
                return "Later"
            }
        }
    }
    
    var sectionHeaders: [String] {
        let sortedKeys = ["Today", "Tomorrow", "Next Few Days", "Later"]
        return sortedKeys.filter { groupedItems.keys.contains($0) }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Spacer()
                    
                    // Sort button
                    Button(action: {
                        showSortOptions = true
                    }) {
                        Image(systemName: "arrow.up.arrow.down")
                            .foregroundColor(Color(UIColor.systemTeal))
                            .font(.system(size: 18))
                    }
                    .padding(.horizontal, 8)
                    
                    // Edit button
                    Button(action: {
                        withAnimation {
                            isEditMode.toggle()
                            if !isEditMode {
                                selectedItems.removeAll()
                            }
                        }
                    }) {
                        Text(isEditMode ? "Done" : "Edit")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(UIColor.systemTeal))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search your food", text: $searchText)
                        .font(.system(size: 16))
                    
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
                .padding(.horizontal, 16)
                .padding(.top, 12)
                
                // Empty state
                if sortedItems.isEmpty {
                    VStack(spacing: 24) {
                        Spacer()
                        
                        Image(systemName: "bag")
                            .font(.system(size: 70))
                            .foregroundColor(Color.gray.opacity(0.6))
                        
                        Text("Your basket is empty")
                            .font(.title3)
                            .fontWeight(.medium)
                        
                        Text("Add food items to keep track of their freshness")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button(action: {
                            // Action to add items
                        }) {
                            Text("Add Food Items")
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
                }
                else {
                    // List with sections
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            if isEditMode {
                                HStack {
                                    Button(action: {
                                        if selectedItems.count == sortedItems.count {
                                            selectedItems.removeAll()
                                        } else {
                                            selectedItems = Set(sortedItems.map { $0.id })
                                        }
                                    }) {
                                        Text(selectedItems.count == sortedItems.count ? "Deselect All" : "Select All")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(Color(UIColor.systemTeal))
                                    }
                                    
                                    Spacer()
                                    
                                    if !selectedItems.isEmpty {
                                        Button(action: {
                                            // Delete selected items
                                            foodItems.removeAll(where: { selectedItems.contains($0.id) })
                                            selectedItems.removeAll()
                                        }) {
                                            Text("Delete Selected")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 12)
                                .padding(.bottom, 4)
                            }
                            
                            ForEach(sectionHeaders, id: \.self) { section in
                                // Section header
                                HStack(spacing: 8) {
                                    Text(section)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    if section == "Today" || section == "Tomorrow" {
                                        Circle()
                                            .fill(section == "Today" ? Color.red : Color.orange)
                                            .frame(width: 8, height: 8)
                                    }
                                    
                                    Text("(\(groupedItems[section]?.count ?? 0))")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 20)
                                .padding(.bottom, 10)
                                
                                // Items in section
                                ForEach(groupedItems[section] ?? [], id: \.id) { item in
                                    BasketItemRow(
                                        item: item,
                                        isEditMode: isEditMode,
                                        isSelected: selectedItems.contains(item.id),
                                        onToggleSelection: { toggleSelection(for: item) }
                                    )
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                }
                            }
                            
                            // Bottom padding to account for tab bar
                            Color.clear.frame(height: 100)
                        }
                    }
                }
            }
            .sheet(isPresented: $showSortOptions) {
                // Sort options menu
                VStack(spacing: 0) {
                    // Header with drag indicator
                    VStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 2.5)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 36, height: 5)
                        
                        Text("Sort By")
                            .font(.headline)
                            .padding(.bottom, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)
                    
                    // Options
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Button(action: {
                            sortOption = option
                            showSortOptions = false
                        }) {
                            HStack {
                                Text(option.rawValue)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if sortOption == option {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color(UIColor.systemTeal))
                                }
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal, 24)
                        }
                        
                        if option != SortOption.allCases.last {
                            Divider()
                                .padding(.horizontal, 24)
                        }
                    }
                    
                    // Cancel button
                    Button(action: {
                        showSortOptions = false
                    }) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                    }
                    
                    Spacer().frame(height: 30)
                }
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .if(UIDevice.current.userInterfaceIdiom == .pad) { view in
                    view.frame(width: 375)
                }
                .if(UIDevice.current.userInterfaceIdiom != .pad) { view in
                    view.edgesIgnoringSafeArea(.bottom)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func toggleSelection(for item: FoodItem) {
        if selectedItems.contains(item.id) {
            selectedItems.remove(item.id)
        } else {
            selectedItems.insert(item.id)
        }
    }
}

// Extension for optional view modifiers
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// Item row component
struct BasketItemRow: View {
    let item: FoodItem
    let isEditMode: Bool
    let isSelected: Bool
    let onToggleSelection: () -> Void
    
    // Map food items to SF Symbols
    private var symbolName: String {
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
    
    // Background color based on the item
    private var bgColor: Color {
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
    
    // Format date as "dd MMM"
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: item.expiryDate)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Selection checkbox in edit mode
            if isEditMode {
                Button(action: onToggleSelection) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? Color(UIColor.systemTeal) : Color.gray.opacity(0.5))
                }
                .padding(.trailing, 2)
            }
            
            // Food icon with background
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(bgColor)
                    .frame(width: 52, height: 52)
                
                Image(systemName: symbolName)
                    .font(.system(size: 24))
                    .foregroundColor(bgColor.opacity(2))
            }
            
            // Food details
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    // Store tag
                    Text(item.store)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    // Separator
                    Text("•")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    // Expiry date
                    Text(item.expiryText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(expiryColor)
                }
            }
            
            Spacer()
            
            // Date tag
            Text(formattedDate)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.gray.opacity(0.1))
                )
            
            // Swipe actions or chevron
            if !isEditMode {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
}

#Preview {
    BasketView()
        .preferredColorScheme(.light)
}
