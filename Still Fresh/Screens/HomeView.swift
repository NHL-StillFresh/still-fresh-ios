import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = FoodTipsViewModel(apiKey: APIKeys.openRouterAPIKey)
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Tips carousel
                TipsCarouselView(tips: viewModel.dailyTips.tips, onRefresh: {
                    viewModel.forceRefreshTips()
                })
                .padding(.top)
                
                Divider()
                    .padding(.horizontal)
                
                // Rest of the home view content
                VStack {
                    Image(systemName: "globe")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                    Text("Hello, Home!")
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            if viewModel.dailyTips.tips.isEmpty {
                viewModel.generateTips()
            }
        }
        .alert(isPresented: Binding(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.error = nil } }
        )) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.error ?? "Unknown error"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

#Preview {
    HomeView()
}
