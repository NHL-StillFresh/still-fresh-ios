import SwiftUI

// Import custom AppState

struct HomeView: View {
    @StateObject private var tipsViewModel = FoodTipsViewModel()
    @StateObject private var recipesViewModel = RecipesViewModel()
    @StateObject private var appStore = AppStore.shared
    
    // Animation states
    @State private var tipsOpacity = 0.0
    @State private var expiringItemsOpacity = 0.0
    @State private var recipesOpacity = 0.0
    @State private var tipsOffset: CGFloat = 30
    @State private var expiringItemsOffset: CGFloat = 40
    @State private var recipesOffset: CGFloat = 50
    
    // Time-based greeting
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "Good morning"
        case 12..<17:
            return "Good afternoon"
        default:
            return "Good evening"
        }
    }
    
    // House selection items
    private var houseSelectionItems: [DropdownItem] {
        appStore.userHouses.map { house in
            DropdownItem(
                title: house.houseName,
                items: nil
            )
        }
    }
    @State private var foodItems: [FoodItem] = []
    @State private var showInventoryView = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Greeting and House Selection
            VStack(alignment: .leading, spacing: 8) {
                Text(greeting)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                AnimatedDropdownMenu(
                    title: appStore.selectedHouse?.houseName ?? "Select House",
                    items: houseSelectionItems,
                    onSelect: { item in
                        // Find the house with matching name and select it
                        if let house = appStore.userHouses.first(where: { $0.houseName == item.title }) {
                            Task {
                                await appStore.selectHouse(houseId: house.houseId)
                                print("DEBUG [HomeView] House selected - Name: \(house.houseName), ID: \(house.houseId)")
                            }
                        }
                    }
                )
                .padding(.horizontal)
            }
            .padding(.top)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Tips carousel
                    TipsCarouselView(tips: tipsViewModel.dailyTips.tips, onRefresh: {
                        tipsViewModel.forceRefreshTips()
                    })
                    .opacity(tipsOpacity)
                    .offset(y: tipsOffset)
                    
                    // Expiring items carousel
                    ExpiringItemsCarouselView(
                        items: expiringItemsViewModel.expiringItems,
                        onSeeAllTapped: {
                            expiringItemsViewModel.seeAllItems()
                        }
                    )
                    .opacity(expiringItemsOpacity)
                    .offset(y: expiringItemsOffset)
                    
                    // Last minute recipes carousel
                    LastMinuteRecipesCarouselView(
                        recipes: recipesViewModel.recipes,
                    )
                    .opacity(recipesOpacity)
                    .offset(y: recipesOffset)
                    
                    Spacer(minLength: 30)
                }
            }
        }
        .task {
            await appStore.loadUserHouses()
            print("DEBUG [HomeView] Houses loaded - Count: \(appStore.userHouses.count)")
            print("DEBUG [HomeView] Selected house: \(appStore.selectedHouse?.houseName ?? "None")")
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
        .alert("Error", isPresented: .constant(appStore.errorMessage != nil)) {
            Button("OK", role: .cancel) {
                appStore.errorMessage = nil
            }
        } message: {
            Text(appStore.errorMessage ?? "Unknown error")
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
