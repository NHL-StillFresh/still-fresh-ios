import SwiftUI

struct BottomNavBar: View {
    @Binding var selectedTab: Int
    @State private var showAddSheet = false
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                            .environment(\.symbolVariants, selectedTab == 0 ? .fill : .none)
                        Text("Home")
                    }.tag(0)

                BasketView()
                    .tabItem {
                        Image(systemName: selectedTab == 1 ? "bag.fill" : "bag")
                            .environment(\.symbolVariants, selectedTab == 1 ? .fill : .none)
                        Text("Basket")
                    }.tag(1)
                
                Color.clear
                    .tabItem {
                        Image(systemName: "")
                        Text("")
                    }.tag(2)

                SearchView()
                    .tabItem {
                        Image(systemName: selectedTab == 3 ? "magnifyingglass" : "magnifyingglass")
                        Text("Search")
                    }.tag(3)

                NotificationsView()
                    .tabItem {
                        Image(systemName: selectedTab == 4 ? "bell.fill" : "bell")
                            .environment(\.symbolVariants, selectedTab == 4 ? .fill : .none)
                        Text("Alerts")
                    }.tag(4)
            }
            .accentColor(Color(UIColor.systemTeal))
            .onChange(of: selectedTab) { newTab in
                // If the middle tab is selected, revert to previous tab and show the add sheet
                if newTab == 2 {
                    // Show add sheet when middle tab is tapped
                    showAddSheet = true
                    // Revert to previous tab or default to first tab
                    selectedTab = max(0, selectedTab == 2 ? 0 : selectedTab)
                }
            }
            .onAppear {
                // Set the background color and appearance of tab bar
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = .white
                
                // Set the appearance of tab items
                let itemAppearance = UITabBarItemAppearance()
                
                // Normal state (unselected)
                itemAppearance.normal.iconColor = .systemGray
                itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray]
                
                // Selected state
                itemAppearance.selected.iconColor = UIColor.systemTeal
                itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemTeal]
                
                appearance.stackedLayoutAppearance = itemAppearance
                
                UITabBar.appearance().standardAppearance = appearance
                if #available(iOS 15.0, *) {
                    UITabBar.appearance().scrollEdgeAppearance = appearance
                }
            }

            // Floating Action Button
            VStack {
                Spacer()
                Button(action: {
                    showAddSheet = true
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                        .frame(width: 72, height: 72)
                        .background(Color(red: 0.04, green: 0.29, blue: 0.29))
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                }
                .padding(20) // Add padding to increase tap area
                .contentShape(Circle().size(CGSize(width: 112, height: 112))) // Increase hit area
                .sheet(isPresented: $showAddSheet) {
                    if #available(iOS 16.0, *) {
                        AddView()
                            .presentationDetents([.height(320)])
                            .presentationDragIndicator(.visible)
                            .presentationCornerRadius(24)
                    } else {
                        // Fallback for iOS 15 and earlier
                        AddView()
                    }
                }
                .offset(y: 50)
                Spacer().frame(height: 40)
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedTab = 0
    
    BottomNavBar(selectedTab: $selectedTab)
}
