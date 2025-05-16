import SwiftUI

struct HomeView: View {
    @StateObject private var tipsViewModel = FoodTipsViewModel(apiKey: APIKeys.openRouterAPIKey)
    @StateObject private var expiringItemsViewModel = ExpiringItemsViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Tips carousel
                TipsCarouselView(tips: tipsViewModel.dailyTips.tips, onRefresh: {
                    tipsViewModel.forceRefreshTips()
                })
                .padding(.top)
                
                Spacer()
                
                // Expiring items carousel
                ExpiringItemsCarouselView(
                    items: expiringItemsViewModel.expiringItems,
                    onSeeAllTapped: {
                        expiringItemsViewModel.seeAllItems()
                    }
                )
            }
        }
        .onAppear {
            if tipsViewModel.dailyTips.tips.isEmpty {
                tipsViewModel.generateTips()
            }
        }
        .alert(isPresented: Binding(
            get: { tipsViewModel.error != nil },
            set: { if !$0 { tipsViewModel.error = nil } }
        )) {
            Alert(
                title: Text("Error"),
                message: Text(tipsViewModel.error ?? "Unknown error"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

#Preview {
    HomeView()
}
