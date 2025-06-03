import SwiftUI

// Dropdown menu item model
struct DropdownItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    var items: [DropdownItem]?
}

// Animated dropdown menu component
struct AnimatedDropdownMenu: View {
    let title: String
    let items: [DropdownItem]
    @State private var isExpanded = false
    @State private var selectedItem: DropdownItem?
    private let tealColor = Color(UIColor.systemTeal)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header/Title button
            Button(action: {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .rotationEffect(.degrees(isExpanded ? 0 : 0))
                        .animation(.spring(), value: isExpanded)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            }
            
            // Dropdown content
            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(items) { item in
                        DropdownItemRow(item: item, selectedItem: $selectedItem, tealColor: tealColor)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 4)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}

// Dropdown item row component
struct DropdownItemRow: View {
    let item: DropdownItem
    @Binding var selectedItem: DropdownItem?
    @State private var isExpanded = false
    let tealColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                if item.items != nil {
                    withAnimation(.spring()) {
                        isExpanded.toggle()
                    }
                } else {
                    selectedItem = item
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: item.icon)
                        .frame(width: 24, height: 24)
                        .foregroundColor(tealColor)
                    
                    Text(item.title)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if item.items != nil {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(selectedItem?.id == item.id ? Color(.systemGray6) : Color.clear)
                .cornerRadius(8)
            }
            
            // Nested items
            if isExpanded, let subItems = item.items {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(subItems) { subItem in
                        DropdownItemRow(item: subItem, selectedItem: $selectedItem, tealColor: tealColor)
                            .padding(.leading, 16)
                    }
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}

#Preview {
    AnimatedDropdownMenu(
        title: "Menu Options",
        items: [
            DropdownItem(
                title: "First Option",
                icon: "star.fill",
                items: [
                    DropdownItem(title: "Sub-option 1", icon: "circle.fill", items: nil),
                    DropdownItem(title: "Sub-option 2", icon: "square.fill", items: nil)
                ]
            ),
            DropdownItem(title: "Second Option", icon: "heart.fill", items: nil)
        ]
    )
    .padding()
    .previewLayout(.sizeThatFits)
}
