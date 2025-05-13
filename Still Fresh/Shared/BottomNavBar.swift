import SwiftUI

struct BottomNavBar: View {
    @Binding var selectedTab: Int
    @Binding var showAddScreen: Bool
    
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
                
                EmptyView()
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
                    showAddScreen.toggle()
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                        .frame(width: 72, height: 72)
                        .background(Color(red: 0.04, green: 0.29, blue: 0.29))
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                }
                .sheet(isPresented: $showAddScreen) {
                    AddView()
                }
                .offset(y: 30)
                Spacer().frame(height: 40)
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedTab = 0
    @Previewable @State var showAddScreen = false
    
    BottomNavBar(selectedTab: $selectedTab, showAddScreen: $showAddScreen)
}
