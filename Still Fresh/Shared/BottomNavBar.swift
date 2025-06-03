import SwiftUI

struct BottomNavBar: View {
    @Binding var selectedTab: Int
    @State private var showAddSheet : Bool = false
    @State private var sheetHeight : PresentationDetent = .height(320)
    
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
                .offset(y: 50)
                Spacer().frame(height: 40)
            }
            
//            if showAddSheet {
//                Color.black.opacity(0.001)
//                    .edgesIgnoringSafeArea(.all)
//                    .onTapGesture {
//                        showAddSheet = false
//                    }
//            }
        }.sheet(isPresented: $showAddSheet) {
            AddView()
                .presentationDetents([sheetHeight], selection: $sheetHeight)
                .interactiveDismissDisabled(false)
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(24)
                .presentationCompactAdaptation(.none)
//                .gesture(
//                    DragGesture()
//                    .onChanged { value in
//                            let translationY = value.translation.height
//                            if translationY > 0 {
//                                self.showAddSheet = false
//                            }
//                        }
//                )
        }
    }
}

#Preview {
    @Previewable @State var selectedTab = 0
    
    BottomNavBar(selectedTab: $selectedTab)
}
