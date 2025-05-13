import SwiftUI

struct ExpiringItemsCarouselView: View {
    let items: [FoodItem]
    var onSeeAllTapped: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with "See All" button
            HStack {
                Text("Use it or lose it")
                    .font(.system(size: 21))
                    .padding(.bottom, 8)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: onSeeAllTapped) {
                    Text("See all")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 122/255, green: 190/255, blue: 203/255))
                        .padding(.bottom, 8)
                }
            }
            .padding(.horizontal)
            
            if items.isEmpty {
                // Empty state
                VStack {
                    Text("No expiring items")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                    Text("Add items to track their expiry dates")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(height: 280) // Match card height
                .frame(maxWidth: .infinity)
            } else {
                // Scrollable carousel of food items
                GeometryReader { outerGeometry in
                    let cardWidth = UIScreen.main.bounds.width * 0.75
                    let cardSpacing: CGFloat = 16
                    let leftEdgePadding: CGFloat = 16
                    
                    ZStack(alignment: .leading) {
                        // Main horizontal scroll content
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: cardSpacing) {
                                ForEach(items) { item in
                                    FoodItemCardView(item: item)
                                }
                                .id(UUID()) // Force layout refresh
                            }
                            .padding(.leading, leftEdgePadding)
                            .padding(.trailing, leftEdgePadding)
                        }
                    }
                }
                .frame(height: 300) // Allow space for the card + shadow
            }
        }
    }
}

#Preview {
    ExpiringItemsCarouselView(
        items: FoodItem.sampleItems,
        onSeeAllTapped: {}
    )
} 