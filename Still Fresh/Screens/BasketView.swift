import SwiftUI

struct BasketView: View {
    @State private var isLoading = false
    @State private var isEditMode = false
    @State private var showAddView = false
    @State private var showErrorAlert = false
    @State private var selectedItems: Set<UUID> = []
    @State private var sheetHeight : PresentationDetent = .height(320)

    @State var sectionHeaders: [BasketSectionHeader] = []
    @State var groupedItems: [BasketSectionHeader: [FoodItem]] = [:]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: isLoading || sectionHeaders.isEmpty ? .center : .leading, spacing: 10) {
                    if isLoading {
                        VStack(spacing: 12) {
                            Spacer()
                            
                            ProgressView()
                            
                            Text("We are loading your inventory...")
                        }
                    } else if (sectionHeaders.isEmpty) {
                        VStack(spacing: 24) {
                            Spacer()
                            
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 50))
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Text("No items found")
                                .font(.title3)
                                .fontWeight(.medium)
                            
                            Button(action: {
                                showAddView = true
                            }) {
                                Text("Add item")
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
                        if (sectionHeaders.contains(.today)) {
                            FoodItemSectionView(
                                section: .today,
                                items: groupedItems[.today] ?? [],
                                isEditMode: isEditMode,
                                selectedItems: selectedItems,
                                onToggleSelection: toggleSelection,
                                onDeleteItem: deleteItem,
                                onRefreshData: refreshData
                            )
                        }
                        
                        if (sectionHeaders.contains(.tomorrow)) {
                            FoodItemSectionView(
                                section: .tomorrow,
                                items: groupedItems[.tomorrow] ?? [],
                                isEditMode: isEditMode,
                                selectedItems: selectedItems,
                                onToggleSelection: toggleSelection,
                                onDeleteItem: deleteItem,
                                onRefreshData: refreshData
                            )
                        }
                        
                        if (sectionHeaders.contains(.later)) {
                            FoodItemSectionView(
                                section: .later,
                                items: groupedItems[.later] ?? [],
                                isEditMode: isEditMode,
                                selectedItems: selectedItems,
                                onToggleSelection: toggleSelection,
                                onDeleteItem: deleteItem,
                                onRefreshData: refreshData
                            )
                        }
                        
                    }
                }
                .padding(.top, 16)
            }
            .toolbar {
                if !sectionHeaders.isEmpty {
                    if isEditMode {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                deleteSelectedItems()
                            }) {
                                Image(systemName: "trash")
                                    .foregroundStyle(selectedItems.isEmpty ? Color.gray : Color.red)
                                    .frame(width: 32, height: 32)
                            }
                            .disabled(selectedItems.isEmpty)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isEditMode.toggle()
                            if !isEditMode {
                                selectedItems.removeAll()
                            }
                        }) {
                            Text(isEditMode ? "Done" : "Edit")
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddView) {
                AddView()
                    .presentationDetents([sheetHeight], selection: $sheetHeight)
                    .interactiveDismissDisabled(false)
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(24)
                    .presentationCompactAdaptation(.none)
            }
        }
        .alert("Error loading data",
               isPresented: $showErrorAlert) {
            Button("Close", role: .cancel) {}
        }
        .onAppear() {
            refreshData()
        }
    }

    private func toggleSelection(for item: FoodItem) {
        if selectedItems.contains(item.id) {
            selectedItems.remove(item.id)
        } else {
            selectedItems.insert(item.id)
        }
    }
    
    private func deleteItem(_ item: FoodItem) {
        guard let houseInventoryId = item.house_inventory_id else {
            print("Cannot delete item: missing house_inventory_id")
            return
        }
        
        Task {
            do {
                try await BasketHandler.deleteInventoryItem(houseInventoryId: houseInventoryId)
                await MainActor.run {
                    refreshData()
                }
            } catch {
                print("Error deleting item: \(error)")
                await MainActor.run {
                    showErrorAlert = true
                }
            }
        }
    }
    
    private func deleteSelectedItems() {
        let selectedFoodItems = getAllSelectedItems()
        let houseInventoryIds = selectedFoodItems.compactMap { $0.house_inventory_id }
        
        guard !houseInventoryIds.isEmpty else {
            print("No valid items selected for deletion")
            return
        }
        
        Task {
            do {
                try await BasketHandler.deleteMultipleInventoryItems(houseInventoryIds: houseInventoryIds)
                await MainActor.run {
                    selectedItems.removeAll()
                    isEditMode = false
                    refreshData()
                }
            } catch {
                print("Error deleting selected items: \(error)")
                await MainActor.run {
                    showErrorAlert = true
                }
            }
        }
    }
    
    private func getAllSelectedItems() -> [FoodItem] {
        var allItems: [FoodItem] = []
        for (_, items) in groupedItems {
            allItems.append(contentsOf: items.filter { selectedItems.contains($0.id) })
        }
        return allItems
    }
    
    private func refreshData() {
        isLoading = true
        
        Task {
            do {
                let results = try await BasketHandler.getBasketProductsSortedOnHeader()
                
                await MainActor.run {
                    sectionHeaders = results.keys.map({ result in
                        return result
                    })
                    groupedItems = results
                    isLoading = false
                }
            } catch {
                print("Error: \(error)")
                await MainActor.run {
                    showErrorAlert = true
                    isLoading = false
                }
            }
        }
    }
}


struct FoodItemSectionView: View {
    let section: BasketSectionHeader
    let items: [FoodItem]
    let isEditMode: Bool
    let selectedItems: Set<UUID>
    let onToggleSelection: (FoodItem) -> Void
    let onDeleteItem: (FoodItem) -> Void
    let onRefreshData: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text(section.description)
                    .font(.headline)
                    .foregroundColor(.primary)
                if section == .today || section == .tomorrow {
                    Circle()
                        .fill(section == .today ? .red : .orange)
                        .frame(width: 8, height: 8)
                }
                Text("(\(items.count))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 16)
            
            // Use native SwiftUI List for proper swipe-to-delete behavior
            if !isEditMode {
                List {
                    ForEach(items) { item in
                        FoodItemRowView(
                            item: item,
                            isSearchObject: false,
                            isEditMode: isEditMode,
                            isSelected: selectedItems.contains(item.id),
                            onToggleSelection: { onToggleSelection(item) },
                            buttonIcon: "chevron.right",
                            showSwipeToDelete: false
                        )
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 3, leading: 16, bottom: 3, trailing: 16))
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive, action: {
                                onDeleteItem(item)
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .frame(height: CGFloat(items.count) * 90) // Approximate height per item
                .scrollDisabled(true)
            } else {
                // Use VStack for edit mode
                VStack(spacing: 0) {
                    ForEach(items) { item in
                        FoodItemRowView(
                            item: item,
                            isSearchObject: false,
                            isEditMode: isEditMode,
                            isSelected: selectedItems.contains(item.id),
                            onToggleSelection: { onToggleSelection(item) },
                            buttonIcon: "chevron.right",
                            showSwipeToDelete: false
                        )
                        .padding(.vertical, 6)
                        .padding(.horizontal, 16)
                    }
                }
            }
        }
        .padding(.top, 20)
    }
}
#Preview {
    BasketView()
}
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
