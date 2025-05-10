import SwiftUI

struct BottomNavBar: View {
    @Binding var selectedTab: Int
    @Binding var showAddScreen: Bool
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }.tag(0)

                BasketView()
                    .tabItem {
                        Image(systemName: "bag")
                        Text("Basket")
                    }.tag(1)
                
                EmptyView()
                    .tabItem {
                        Image(systemName: "")
                        Text("")
                    }.tag(2)

                SearchView()
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }.tag(3)

                NotificationsView()
                    .tabItem {
                        Image(systemName: "bell")
                        Text("Alerts")
                    }.tag(4)
            }

            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showAddScreen.toggle()
                    }) {
                        Image(systemName: "camera.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 24))
                            .frame(width: 60, height: 60)
                            .background(Color.black)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .sheet(isPresented: $showAddScreen) {
                        AddView()
                    }
                    .offset(y: -30)
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedTab = 0
    @Previewable @State var showAddScreen = false
    
    BottomNavBar(selectedTab: $selectedTab, showAddScreen: $showAddScreen)
}
