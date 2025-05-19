import SwiftUI

struct LastMinuteRecipesCarouselView: View {
    let recipes: [Recipe]
    var onSeeAllTapped: () -> Void
    
    @State private var currentPage = 0
    @State private var dragOffset: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var isUserScrolling = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with "See All" button
            HStack {
                Text("Last minute recipes")
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
            
            if recipes.isEmpty {
                // Empty state
                VStack {
                    Text("No recipes available")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                    Text("Check back later for quick recipe ideas")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(height: 250)
                .frame(maxWidth: .infinity)
            } else {
                // Scrollable carousel of recipes
                GeometryReader { outerGeometry in
                    let cardWidth = UIScreen.main.bounds.width * 0.6
                    let cardSpacing: CGFloat = 16
                    let leftEdgePadding: CGFloat = 16
                    
                    ZStack(alignment: .leading) {
                        // Main horizontal scroll content
                        HStack(spacing: cardSpacing) {
                            ForEach(0..<recipes.count, id: \.self) { index in
                                RecipeCardView(recipe: recipes[index])
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
                                        if velocity < 0 && currentPage < recipes.count - 1 {
                                            currentPage += 1
                                        } else if velocity > 0 && currentPage > 0 {
                                            currentPage -= 1
                                        }
                                    } else {
                                        // Swipe without much velocity - calculate nearest page
                                        let offsetInCardWidths = -scrollOffset / cardTotalWidth
                                        let nearestPage = Int(round(offsetInCardWidths))
                                        currentPage = max(0, min(recipes.count - 1, nearestPage))
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
                .frame(height: 250)
            }
        }
    }
}

#Preview {
    LastMinuteRecipesCarouselView(
        recipes: Recipe.sampleRecipes,
        onSeeAllTapped: {}
    )
} 