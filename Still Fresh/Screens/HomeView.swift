import SwiftUI

// Import custom AppState

struct HomeView: View {
    @StateObject private var tipsViewModel = FoodTipsViewModel()
    @StateObject private var recipesViewModel = RecipesViewModel()
    
    // Animation states
    @State private var tipsOpacity = 0.0
    @State private var expiringItemsOpacity = 0.0
    @State private var recipesOpacity = 0.0
    @State private var tipsOffset: CGFloat = 30
    @State private var expiringItemsOffset: CGFloat = 40
    @State private var recipesOffset: CGFloat = 50
    
    @State private var foodItems: [FoodItem] = []
    @State private var showInventoryView = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Tips carousel
                TipsCarouselView(tips: tipsViewModel.dailyTips.tips, onRefresh: {
                    tipsViewModel.forceRefreshTips()
                })
                .padding(.top)
                .opacity(tipsOpacity)
                .offset(y: tipsOffset)
                
                // Expiring items carousel
                ExpiringItemsCarouselView(
                    items: foodItems,
                    onSeeAllTapped: {
                        showInventoryView = true
                    }
                )
                .opacity(expiringItemsOpacity)
                .offset(y: expiringItemsOffset)
                
                // Last minute recipes carousel
                LastMinuteRecipesCarouselView(
                    recipes: recipesViewModel.lastMinuteRecipes,
                    onSeeAllTapped: {
                        recipesViewModel.seeAllRecipes()
                    }
                )
                .opacity(recipesOpacity)
                .offset(y: recipesOffset)
                
                Spacer(minLength: 30)
            }
        }
        .onAppear {
            if tipsViewModel.dailyTips.tips.isEmpty {
                tipsViewModel.generateTips()
            }
            
            getBasketItems()
            
            let shouldAnimate = UserDefaults.standard.bool(forKey: "shouldAnimateHomeView")
            
            if shouldAnimate {
                animateItemsIn()
                UserDefaults.standard.set(false, forKey: "shouldAnimateHomeView")
            } else {
                showItemsWithoutAnimation()
            }
        }
        .sheet(isPresented: $showInventoryView) {
            BasketView()
        }
//        .alert(isPresented: Binding(
//            get: { tipsViewModel.error != nil },
//            set: { if !$0 { tipsViewModel.error = nil } }
//        )) {
//            Alert(
//                title: Text("Error"),
//                message: Text(tipsViewModel.error ?? "Unknown error"),
//                dismissButton: .default(Text("OK"))
//            )
//        }
    }
    
    private func getBasketItems() {
        Task {
            do{
                self.foodItems = try await BasketHandler.getBasketProducts()
                
                await setProductNotificationsFromBasket();
            } catch {
                print("Products cannot be loaded: \(error)")
            }
        }
    }
    
    private func animateItemsIn() {
        // Tips animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
            tipsOpacity = 1
            tipsOffset = 0
        }
        
        // Expiring items animation with delay
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3)) {
            expiringItemsOpacity = 1
            expiringItemsOffset = 0
        }
        
        // Recipes animation with longer delay
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.5)) {
            recipesOpacity = 1
            recipesOffset = 0
        }
    }
    
    private func showItemsWithoutAnimation() {
        tipsOpacity = 1
        expiringItemsOpacity = 1
        recipesOpacity = 1
        tipsOffset = 0
        expiringItemsOffset = 0
        recipesOffset = 0
    }
}

#Preview {
    HomeView()
}
