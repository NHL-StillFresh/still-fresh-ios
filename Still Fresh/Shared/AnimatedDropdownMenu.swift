import SwiftUI

// Dropdown menu item model
struct DropdownItem: Identifiable {
    let id = UUID()
    let title: String
    var items: [DropdownItem]?
}

// Animated dropdown menu component
struct AnimatedDropdownMenu: View {
    let title: String
    let items: [DropdownItem]
    let onSelect: ((DropdownItem) -> Void)?
    
    @State private var isExpanded = false
    @State private var selectedItem: DropdownItem?
    
    // Ocean theme colors
    private let oceanBlue = Color(red: 0.0, green: 0.5, blue: 0.7)
    private let lightOceanBlue = Color(red: 0.8, green: 0.9, blue: 1.0)
    private let deepBlue = Color(red: 0.0, green: 0.3, blue: 0.6)
    
    init(
        title: String,
        items: [DropdownItem],
        onSelect: ((DropdownItem) -> Void)? = nil
    ) {
        self.title = title
        self.items = items
        self.onSelect = onSelect
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header/Title button
            Button(action: {
                if !items.isEmpty {
                    withAnimation(.spring()) {
                        isExpanded.toggle()
                    }
                }
            }) {
                HStack {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(oceanBlue)
                    
                    Spacer()
                    
                    if !items.isEmpty {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(oceanBlue)
                            .rotationEffect(.degrees(isExpanded ? 0 : 0))
                            .animation(.spring(), value: isExpanded)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(lightOceanBlue.opacity(0.3))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(oceanBlue.opacity(0.3), lineWidth: 1)
                )
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.3)
            .disabled(items.isEmpty)
            
            // Dropdown content
            if isExpanded && !items.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(items) { item in
                        CompactDropdownItemRow(
                            item: item,
                            selectedItem: $selectedItem,
                            oceanBlue: oceanBlue,
                            lightOceanBlue: lightOceanBlue,
                            onSelect: { selectedItem in
                                onSelect?(selectedItem)
                                withAnimation(.spring()) {
                                    isExpanded = false
                                }
                            }
                        )
                    }
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemBackground))
                        .shadow(color: oceanBlue.opacity(0.1), radius: 4, x: 0, y: 2)
                )
                .frame(maxWidth: UIScreen.main.bounds.width * 0.3)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}

// Compact dropdown item row component
struct CompactDropdownItemRow: View {
    let item: DropdownItem
    @Binding var selectedItem: DropdownItem?
    @State private var isExpanded = false
    let oceanBlue: Color
    let lightOceanBlue: Color
    let onSelect: ((DropdownItem) -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                if item.items != nil {
                    withAnimation(.spring()) {
                        isExpanded.toggle()
                    }
                } else {
                    selectedItem = item
                    onSelect?(item)
                }
            }) {
                HStack {
                    Text(item.title)
                        .font(.system(size: 14))
                        .fontWeight(selectedItem?.id == item.id ? .bold : .regular)
                        .foregroundColor(selectedItem?.id == item.id ? oceanBlue : .primary)
                    
                    Spacer()
                    
                    if item.items != nil {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(oceanBlue)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    selectedItem?.id == item.id ? 
                        lightOceanBlue.opacity(0.2) : 
                        Color.clear
                )
                .cornerRadius(6)
            }
            
            // Nested items
            if isExpanded, let subItems = item.items {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(subItems) { subItem in
                        CompactDropdownItemRow(
                            item: subItem,
                            selectedItem: $selectedItem,
                            oceanBlue: oceanBlue,
                            lightOceanBlue: lightOceanBlue,
                            onSelect: onSelect
                        )
                        .padding(.leading, 12)
                    }
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}

#Preview {
    AnimatedDropdownMenu(
        title: "Options",
        items: [
            DropdownItem(
                title: "First Option",
                items: [
                    DropdownItem(title: "Sub-option 1", items: nil),
                    DropdownItem(title: "Sub-option 2", items: nil)
                ]
            ),
            DropdownItem(title: "Second Option", items: nil)
        ],
        onSelect: { item in
            print("Selected item: \(item.title)")
        }
    )
    .padding()
    .previewLayout(.sizeThatFits)
}
