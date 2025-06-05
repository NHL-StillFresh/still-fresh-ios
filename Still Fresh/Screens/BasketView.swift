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
                            
                            Text("We are loading your basket...")
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
                        ForEach(sectionHeaders, id: \.self) { section in
                            FoodItemSectionView(
                                section: section,
                                items: groupedItems[section] ?? [],
                                isEditMode: isEditMode,
                                selectedItems: selectedItems,
                                onToggleSelection: toggleSelection
                            )
                        }
                    }
                }
                .padding(.top, 16)
            }
            .toolbar {
                if !sectionHeaders.isEmpty {
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
            isLoading = true
            
            Task {
                do {
                    let results = try await BasketHandler.getBasketProductsSortedOnHeader()
                    
                    sectionHeaders = results.keys.map({
                        result in
                        return result
                    })
                    groupedItems = results
                                        
                } catch {
                    print("Error: \(error)")
                    showErrorAlert = true
                }
                
                isLoading = false
            }
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


struct FoodItemSectionView: View {
    let section: BasketSectionHeader
    let items: [FoodItem]
    let isEditMode: Bool
    let selectedItems: Set<UUID>
    let onToggleSelection: (FoodItem) -> Void

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
            ForEach(items) { item in
                FoodItemRowView(item: item,
                                isSearchObject: false,
                                isEditMode: isEditMode,
                                isSelected: selectedItems.contains(item.id),
                                onToggleSelection: { onToggleSelection(item) },
                                buttonIcon: "chevron.right"
                )
                .padding(.vertical, 6)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
    }
}

//
//struct SortOptionSheet: View {
//    @Binding var sortOption: BasketView.SortOption
//    @Binding var showSortOptions: Bool
//
//    var body: some View {
//        VStack(spacing: 0) {
//            VStack(spacing: 8) {
//                RoundedRectangle(cornerRadius: 2.5)
//                    .fill(Color.gray.opacity(0.3))
//                    .frame(width: 36, height: 5)
//                Text("Sort By")
//                    .font(.headline)
//                    .padding(.bottom, 8)
//            }
//            .frame(maxWidth: .infinity)
//            .padding(.top, 12)
//            ForEach(BasketView.SortOption.allCases, id: \.self) { option in
//                Button(action: {
//                    sortOption = option
//                    showSortOptions = false
//                }) {
//                    HStack {
//                        Text(option.rawValue)
//                            .foregroundColor(.primary)
//                        Spacer()
//                        if sortOption == option {
//                            Image(systemName: "checkmark")
//                                .foregroundColor(Color(UIColor.systemTeal))
//                        }
//                    }
//                    .padding(.vertical, 14)
//                    .padding(.horizontal, 24)
//                }
//                if option != BasketView.SortOption.allCases.last {
//                    Divider().padding(.horizontal, 24)
//                }
//            }
//            Button(action: { showSortOptions = false }) {
//                Text("Cancel")
//                    .font(.system(size: 16, weight: .semibold))
//                    .foregroundColor(.primary)
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 16)
//                    .background(Color(.systemGray6))
//                    .cornerRadius(12)
//                    .padding(.horizontal, 24)
//                    .padding(.top, 20)
//            }
//            Spacer().frame(height: 30)
//        }
//        .background(Color(.systemBackground))
//        .cornerRadius(20)
//    }
//}

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
