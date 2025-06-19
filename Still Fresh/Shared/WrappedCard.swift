import SwiftUI

struct WrappedCard: View {
    @State private var isGlowing = false
    @State private var rotation = 0.0
    @State private var pulseScale = 1.0
    @State private var shimmerOffset: CGFloat = -200
    
    let wrappedData: WrappedData
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.1)) {
                pulseScale = 0.95
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    pulseScale = 1.0
                }
                onTap()
            }
        }) {
            ZStack {
                // Background gradient
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.2, green: 0.8, blue: 0.6),
                                Color(red: 0.1, green: 0.6, blue: 0.8),
                                Color(red: 0.3, green: 0.7, blue: 0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(
                        color: isGlowing ? Color.cyan.opacity(0.6) : Color.black.opacity(0.3),
                        radius: isGlowing ? 15 : 8,
                        x: 0,
                        y: isGlowing ? 0 : 4
                    )
                
                // Shimmer effect
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: shimmerOffset)
                    .clipped()
                
                // Content
                HStack(spacing: 16) {
                    // Icon with rotation animation
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "gift.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(rotation))
                            .symbolEffect(.pulse, isActive: isGlowing)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Still Fresh Wrapped")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("\(wrappedData.year)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Capsule())
                        }
                        
                        if wrappedData.totalItemsSaved > 0 {
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(wrappedData.totalItemsSaved)")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("items saved")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("€\(String(format: "%.0f", wrappedData.moneySaved))")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("saved")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                        } else {
                            Text("Your year in review awaits!")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(20)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(pulseScale)
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Glow animation
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            isGlowing.toggle()
        }
        
        // Rotation animation
        withAnimation(.linear(duration: 10.0).repeatForever(autoreverses: false)) {
            rotation = 360
        }
        
        // Shimmer animation
        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
            shimmerOffset = UIScreen.main.bounds.width + 200
        }
    }
}

// Preview with sample data
#Preview {
    VStack {
        WrappedCard(
            wrappedData: WrappedData(
                year: 2024,
                totalItemsSaved: 127,
                moneySaved: 317.50,
                mostUsedIngredient: "Garlic",
                mostUsedIngredientCount: 42,
                favoriteRecipe: "Pasta Arrabiata",
                zeroWasteWeeks: 8,
                totalItemsTracked: 145,
                avgDaysUntilExpiry: 6.2,
                topCategories: ["Vegetables", "Fruits", "Dairy"],
                monthlyStats: [],
                achievements: [],
                funInsight: "You're the Garlic Guardian! 🧄",
                generatedAt: Date()
            ),
            onTap: { print("Wrapped tapped!") }
        )
        .padding()
        
        WrappedCard(
            wrappedData: WrappedData.empty,
            onTap: { print("Empty wrapped tapped!") }
        )
        .padding()
    }
    .background(Color(.systemGroupedBackground))
} 