import SwiftUI

// Define a preference key to track card positions
struct CardPreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGRect] = [:]
    
    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue()) { current, _ in current }
    }
}

struct TipsCarouselView: View {
    let tips: [FoodSavingTip]
    let onRefresh: () -> Void
    
    @State private var currentPage = 0
    @State private var cardRects: [Int: CGRect] = [:]
    @State private var isRefreshing = false
    @State private var dragOffset: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var isUserScrolling = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Fresh Hacks")
                    .font(.system(size: 21))
                    .padding(.bottom, 8)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    isRefreshing = true
                    onRefresh()
                    
                    // Auto-reset refreshing status after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        isRefreshing = false
                    }
                }) {
                    if isRefreshing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(Color(UIColor.systemTeal))
                            .padding(.bottom, 8)

                    }
                }
                .disabled(isRefreshing)
            }
            .padding(.horizontal)
            
            if tips.isEmpty {
                VStack {
                    ProgressView()
                    Text("Loading today's tips...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(height: 140)
                .frame(maxWidth: .infinity)
            } else {
                GeometryReader { outerGeometry in
                    let cardWidth = UIScreen.main.bounds.width * 0.75
                    let cardSpacing: CGFloat = 16
                    // Start from the left edge with a small padding
                    let leftEdgePadding: CGFloat = 16
                    
                    ZStack(alignment: .leading) {
                        // Main horizontal scroll content
                        HStack(spacing: cardSpacing) {
                            ForEach(0..<tips.count, id: \.self) { index in
                                TipCardView(tip: tips[index])
                                    .id(index)
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
                                        if velocity < 0 && currentPage < tips.count - 1 {
                                            currentPage += 1
                                        } else if velocity > 0 && currentPage > 0 {
                                            currentPage -= 1
                                        }
                                    } else {
                                        // Swipe without much velocity - calculate nearest page
                                        let offsetInCardWidths = -scrollOffset / cardTotalWidth
                                        let nearestPage = Int(round(offsetInCardWidths))
                                        currentPage = max(0, min(tips.count - 1, nearestPage))
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
                    .frame(height: 140)
                }
                .frame(height: 140)

            }
        }
    }
}

#Preview {
    TipsCarouselView(
        tips: [
            FoodSavingTip(content: "Store cheese in wax paper, not plastic."),
            FoodSavingTip(content: "Keep peeled onions in an airtight container."),
            FoodSavingTip(content: "Store herbs in a jar with water.")
        ],
        onRefresh: {}
    )
} 
