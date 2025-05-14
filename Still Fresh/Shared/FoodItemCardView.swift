import SwiftUI

struct FoodItemCardView: View {
    let item: FoodItem
    
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
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Card background
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
            
            // Content container with no spacing at top
            VStack(alignment: .leading, spacing: 0) {
                // Product image
                ZStack(alignment: .topLeading) {
                    // Food illustration with background
                    ZStack {
                        Rectangle()
                            .fill(bgColor)
                        
                        Image(systemName: symbolName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(24)
                            .foregroundColor(bgColor.opacity(1.5))
                    }
                    .frame(height: 110)
                    .frame(maxWidth: .infinity)
                    
                    // Store tag
                    Text(item.store)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.6))
                        )
                        .padding(12)
                }
                
                // Product details with spacing from image
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    // Expiry information
                    HStack {
                        // Expiry alert
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(expiryColor)
                                .font(.system(size: 12))
                            
                            Text(item.expiryText)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(expiryColor)
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(
                            Capsule()
                                .fill(expiryColor.opacity(0.1))
                        )
                        
                        Spacer()
                        
                        // Date
                        Text(formattedDate)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(
                                Capsule()
                                    .fill(Color.gray.opacity(0.1))
                            )
                    }
                    
                    // Button to view details
                    Button(action: {
                        // TODO: Navigate to product details
                    }) {
                        Text("View Details")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color(red: 122/255, green: 190/255, blue: 203/255))
                            .cornerRadius(10)
                    }
                    .padding(.top, 6)
                }
                .padding(.top, 8)
                .padding(.horizontal, 14)
                .padding(.bottom, 12)
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.6, height: 230)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // Format date as "dd MMM"
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: item.expiryDate)
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

#Preview {
    ScrollView(.horizontal) {
        HStack(spacing: 16) {
            FoodItemCardView(item: FoodItem.sampleItems[0])
            FoodItemCardView(item: FoodItem.sampleItems[1])
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
} 
