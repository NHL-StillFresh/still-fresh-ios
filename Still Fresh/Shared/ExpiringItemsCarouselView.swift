import SwiftUI

struct ExpiringItemsCarouselView: View {
    let items: [FoodItem]
    var onSeeAllTapped: () -> Void
    
    @State private var currentPage = 0
    @State private var dragOffset: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var isUserScrolling = false
    
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
                .frame(height: 250) // Match reduced card height
                .frame(maxWidth: .infinity)
            } else {
                // Scrollable carousel of food items
                GeometryReader { outerGeometry in
                    let cardWidth = UIScreen.main.bounds.width * 0.6
                    let cardSpacing: CGFloat = 16
                    let leftEdgePadding: CGFloat = 16
                    
                    ZStack(alignment: .leading) {
                        // Main horizontal scroll content
                        HStack(spacing: cardSpacing) {
                            ForEach(0..<items.count, id: \.self) { index in
                                FoodItemCardView(item: items[index])
                            }
                        }
                        .offset(x: leftEdgePadding + scrollOffset + dragOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    isUserScrolling = true
                                    dragOffset = value.translation.width
                                }
                                .onEnded { value in
                                    isUserScrolling = false
                                    // Update scrollOffset to include the drag
                                    scrollOffset += dragOffset
                                    dragOffset = 0
                                    
                                    // Calculate which card should be visible
                                    let cardTotalWidth = cardWidth + cardSpacing
                                    
                                    // Calculate the velocity and determine next page
                                    let velocity = value.predictedEndTranslation.width - value.translation.width
                                    let velocityThreshold: CGFloat = 200
                                    
                                    if abs(velocity) > velocityThreshold {
                                        // Swipe with velocity - go to next or previous page based on velocity direction
                                        if velocity < 0 && currentPage < items.count - 1 {
                                            currentPage += 1
                                        } else if velocity > 0 && currentPage > 0 {
                                            currentPage -= 1
                                        }
                                    } else {
                                        // Swipe without much velocity - calculate nearest page
                                        let offsetInCardWidths = -scrollOffset / cardTotalWidth
                                        let nearestPage = Int(round(offsetInCardWidths))
                                        currentPage = max(0, min(items.count - 1, nearestPage))
                                    }
                                    
                                    // Calculate final position for the selected card to be fully visible
                                    let newOffset = -CGFloat(currentPage) * cardTotalWidth
                                    
                                    // Animate to the final position
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        scrollOffset = newOffset
                                    }
                                }
                        )
                    }
                }
                .frame(height: 250) // Reduced to match new card height
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
