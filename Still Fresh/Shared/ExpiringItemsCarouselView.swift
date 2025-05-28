import SwiftUI

struct ExpiringItemsCarouselView: View {
    let items: [FoodItem]
    var onSeeAllTapped: () -> Void
    
    // Sort items by expiry date (most urgent first)
    private var sortedItems: [FoodItem] {
        items.sorted { $0.daysUntilExpiry < $1.daysUntilExpiry }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Text("Use It or Lose It")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: onSeeAllTapped) {
                    Text("See all")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 0.04, green: 0.29, blue: 0.29))
                }
            }
            .padding(.horizontal, 20)
            
            if items.isEmpty {
                // Clean empty state
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(Color(red: 0.04, green: 0.29, blue: 0.29))
                    
                    Text("All items are fresh!")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("No items expiring soon")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                // Clean list of items
                VStack(spacing: 12) {
                    ForEach(sortedItems.prefix(5)) { item in
                        ModernFoodItemRow(item: item)
                    }
                    
                    // Show more items indicator if there are more than 5
                    if sortedItems.count > 5 {
                        Button(action: onSeeAllTapped) {
                            HStack {
                                Text("View \(sortedItems.count - 5) more items")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(Color(red: 0.04, green: 0.29, blue: 0.29))
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Color(red: 0.04, green: 0.29, blue: 0.29))
                            }
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(red: 0.04, green: 0.29, blue: 0.29).opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color(red: 0.04, green: 0.29, blue: 0.29).opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    }
                }
            }
        }
    }
}

struct ModernFoodItemRow: View {
    let item: FoodItem
    @State private var isPressed = false
    
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
    
    // Icon color based on food type
    private var iconColor: Color {
        switch item.name.lowercased() {
        case let name where name.contains("milk") || name.contains("yogurt"):
            return Color.blue
        case let name where name.contains("chicken"):
            return Color.orange
        case let name where name.contains("spinach") || name.contains("veggie"):
            return Color.green
        default:
            return Color(red: 0.04, green: 0.29, blue: 0.29)
        }
    }
    
    // Urgency color based on days until expiry - more subtle styling
    private var urgencyColor: Color {
        switch item.daysUntilExpiry {
        case 0:
            return Color.red.opacity(0.8)
        case 1:
            return Color.orange.opacity(0.8)
        case 2...3:
            return Color.yellow.opacity(0.8)
        default:
            return Color(red: 122/255, green: 190/255, blue: 203/255).opacity(0.8)
        }
    }
    
    // Background color for badges - subtle and consistent with app design
    private var urgencyBackgroundColor: Color {
        switch item.daysUntilExpiry {
        case 0:
            return Color.red.opacity(0.15)
        case 1:
            return Color.orange.opacity(0.15)
        case 2...3:
            return Color.yellow.opacity(0.15)
        default:
            return Color(red: 122/255, green: 190/255, blue: 203/255).opacity(0.15)
        }
    }
    
    // Text color for badges
    private var urgencyTextColor: Color {
        switch item.daysUntilExpiry {
        case 0:
            return Color.red
        case 1:
            return Color.orange
        case 2...3:
            return Color.yellow.opacity(0.8)
        default:
            return Color(red: 122/255, green: 190/255, blue: 203/255)
        }
    }
    
    // Short expiry text for badge
    private var shortExpiryText: String {
        switch item.daysUntilExpiry {
        case 0:
            return "Today"
        case 1:
            return "Tomorrow"
        default:
            return "\(item.daysUntilExpiry)d"
        }
    }
    
    // Format date
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter.string(from: item.expiryDate)
    }
    
    var body: some View {
        Button(action: {
            // TODO: Navigate to item details
        }) {
            HStack(spacing: 16) {
                // Food icon
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: symbolName)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(iconColor)
                }
                
                // Item info
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 8) {
                        Text(item.store)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        Circle()
                            .fill(Color.secondary)
                            .frame(width: 2, height: 2)
                        
                        Text(formattedDate)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Expiry badge
                Text(shortExpiryText)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(urgencyTextColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(urgencyBackgroundColor)
                            .overlay(
                                Capsule()
                                    .stroke(urgencyColor, lineWidth: 0.5)
                            )
                    )
                    .shadow(color: urgencyColor.opacity(0.2), radius: 2, x: 0, y: 1)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents {
            isPressed = true
        } onRelease: {
            isPressed = false
        }
        .padding(.horizontal, 20)
    }
}

// Custom press gesture extension for better control
extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    onPress()
                }
                .onEnded { _ in
                    onRelease()
                }
        )
    }
}

#Preview {
    ScrollView {
        ExpiringItemsCarouselView(
            items: FoodItem.sampleItems,
            onSeeAllTapped: {}
        )
        .padding(.vertical, 20)
    }
    .background(Color(.systemGroupedBackground))
} 
