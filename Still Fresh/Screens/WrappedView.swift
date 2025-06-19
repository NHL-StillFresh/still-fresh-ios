import SwiftUI

struct WrappedView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var soundPlayer = SoundEffectPlayer()
    @Namespace private var animationNamespace
    
    let wrappedData: WrappedData
    
    @State private var currentSlide = 0
    @State private var showConfetti = false
    @State private var slideOffset: CGFloat = 0
    @State private var isAnimating = false
    
    private let totalSlides = 8
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.2, green: 0.1, blue: 0.3),
                    Color(red: 0.1, green: 0.2, blue: 0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Confetti overlay
            if showConfetti {
                ConfettiView(isActive: showConfetti)
                    .allowsHitTesting(false)
            }
            
            // Main content
            VStack(spacing: 0) {
                // Progress bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    // Progress indicators
                    HStack(spacing: 4) {
                        ForEach(0..<totalSlides, id: \.self) { index in
                            Capsule()
                                .fill(index <= currentSlide ? Color.white : Color.white.opacity(0.3))
                                .frame(width: index == currentSlide ? 20 : 8, height: 4)
                                .animation(.easeInOut(duration: 0.3), value: currentSlide)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: shareWrapped) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Slides
                TabView(selection: $currentSlide) {
                    ForEach(0..<totalSlides, id: \.self) { index in
                        slideContent(for: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .onChange(of: currentSlide) { newValue in
                    handleSlideChange(newValue)
                }
            }
        }
        .onAppear {
            startInitialAnimation()
        }
    }
    
    @ViewBuilder
    private func slideContent(for index: Int) -> some View {
        switch index {
        case 0:
            welcomeSlide()
        case 1:
            itemsSavedSlide()
        case 2:
            moneySavedSlide()
        case 3:
            mostUsedIngredientSlide()
        case 4:
            favoriteRecipeSlide()
        case 5:
            streaksSlide()
        case 6:
            achievementsSlide()
        case 7:
            finalSlide()
        default:
            EmptyView()
        }
    }
    
    // MARK: - Slide Implementations
    
    private func welcomeSlide() -> some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("🎉")
                    .font(.system(size: 80))
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isAnimating)
                
                Text("Your \(wrappedData.year)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Still Fresh Wrapped")
                    .font(.system(size: 48, weight: .heavy))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .matchedGeometryEffect(id: "title", in: animationNamespace)
            }
            
            Spacer()
            
            Text("Swipe to see your impact →")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .padding(.bottom, 40)
        }
        .padding(.horizontal, 40)
    }
    
    private func itemsSavedSlide() -> some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("You fought the rot—\nand won! 🛡️")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("\(wrappedData.totalItemsSaved)")
                    .font(.system(size: 80, weight: .heavy))
                    .foregroundColor(.green)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isAnimating)
                
                Text("items saved from spoiling")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            if wrappedData.totalItemsSaved > 50 {
                Text("You're a true food waste warrior!")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.yellow)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 40)
            }
        }
        .padding(.horizontal, 40)
    }
    
    private func moneySavedSlide() -> some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("You saved")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                
                Text("€\(String(format: "%.0f", wrappedData.moneySaved))")
                    .font(.system(size: 72, weight: .heavy))
                    .foregroundColor(.yellow)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isAnimating)
                
                Text("this year—treat yourself! 🍕")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Text("That's enough for \(Int(wrappedData.moneySaved / 4)) coffee dates ☕")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.bottom, 40)
        }
        .padding(.horizontal, 40)
    }
    
    private func mostUsedIngredientSlide() -> some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("Your kitchen MVP:")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                
                Text(getIngredientEmoji(wrappedData.mostUsedIngredient))
                    .font(.system(size: 100))
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isAnimating)
                
                Text(wrappedData.mostUsedIngredient.capitalized)
                    .font(.system(size: 36, weight: .heavy))
                    .foregroundColor(.white)
                
                Text("used \(wrappedData.mostUsedIngredientCount) times")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            Text("You're the \(wrappedData.mostUsedIngredient.capitalized) Champion! 🏆")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.orange)
                .multilineTextAlignment(.center)
                .padding(.bottom, 40)
        }
        .padding(.horizontal, 40)
    }
    
    private func favoriteRecipeSlide() -> some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("Your go-to recipe:")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                
                Text("👨‍🍳")
                    .font(.system(size: 80))
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isAnimating)
                
                Text(wrappedData.favoriteRecipe)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Text("A classic choice! 🍝")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .padding(.bottom, 40)
        }
        .padding(.horizontal, 40)
    }
    
    private func streaksSlide() -> some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("🔥")
                    .font(.system(size: 80))
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isAnimating)
                
                Text("\(wrappedData.zeroWasteWeeks)")
                    .font(.system(size: 72, weight: .heavy))
                    .foregroundColor(.orange)
                
                Text("weeks of zero waste")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Text("You're on fire! Keep the streak going! 🚀")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.bottom, 40)
        }
        .padding(.horizontal, 40)
    }
    
    private func achievementsSlide() -> some View {
        VStack(spacing: 30) {
            Text("Achievements Unlocked!")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 20)
            
            ScrollView {
                VStack(spacing: 16) {
                    if wrappedData.achievements.isEmpty {
                        VStack(spacing: 20) {
                            Text("🎯")
                                .font(.system(size: 60))
                            
                            Text("Keep using Still Fresh to unlock achievements!")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 40)
                    } else {
                        ForEach(wrappedData.achievements) { achievement in
                            achievementCard(achievement)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private func achievementCard(_ achievement: Achievement) -> some View {
        HStack(spacing: 16) {
            Text(achievement.icon)
                .font(.system(size: 32))
                .frame(width: 50, height: 50)
                .background(Color.white.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Text(achievement.description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func finalSlide() -> some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("🌱")
                    .font(.system(size: 80))
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isAnimating)
                
                Text(wrappedData.funInsight)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Thanks for making the planet a little greener!")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                Button(action: shareWrapped) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share Your Wrapped")
                    }
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .clipShape(Capsule())
                }
                
                Button(action: { dismiss() }) {
                    Text("Done")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.vertical, 8)
                }
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 40)
    }
    
    // MARK: - Helper Methods
    
    private func handleSlideChange(_ newSlide: Int) {
        // Stop any existing confetti first
        showConfetti = false
        
        // Small delay then start new effects
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Play sound effects based on slide content
            switch newSlide {
            case 1, 2, 6: // Achievement slides
                soundPlayer.playSuccess()
                showConfetti = true
                // Let confetti run its natural course (3 seconds from ConfettiView)
            case 3, 4: // Fun slides
                soundPlayer.playCheer()
            default:
                soundPlayer.playWhoosh()
            }
        }
    }
    
    private func startInitialAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isAnimating = true
        }
    }
    
    private func getIngredientEmoji(_ ingredient: String) -> String {
        let emojiMap = [
            "garlic": "🧄",
            "onion": "🧅",
            "tomato": "🍅",
            "carrot": "🥕",
            "potato": "🥔",
            "apple": "🍎",
            "banana": "🍌",
            "milk": "🥛",
            "cheese": "🧀",
            "bread": "🍞",
            "egg": "🥚",
            "chicken": "🐔",
            "beef": "🥩",
            "rice": "🍚",
            "pasta": "🍝"
        ]
        
        return emojiMap[ingredient.lowercased()] ?? "🥘"
    }
    
    private func shareWrapped() {
        soundPlayer.playPop()
        // Implement sharing functionality
        let shareText = """
        My Still Fresh Wrapped \(wrappedData.year)! 🎉
        
        ✅ \(wrappedData.totalItemsSaved) items saved from spoiling
        💰 €\(String(format: "%.0f", wrappedData.moneySaved)) saved
        🏆 Most used: \(wrappedData.mostUsedIngredient)
        🔥 \(wrappedData.zeroWasteWeeks) weeks of zero waste
        
        Join me in fighting food waste! #StillFreshWrapped
        """
        
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

#Preview {
    WrappedView(wrappedData: WrappedData(
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
        achievements: [
            Achievement(
                title: "Waste Warrior",
                description: "You saved 50+ items from spoiling!",
                icon: "shield.fill",
                unlockedAt: Date(),
                type: .wasteWarrior
            )
        ],
        funInsight: "You're the Garlic Guardian! 🧄",
        generatedAt: Date()
    ))
} 