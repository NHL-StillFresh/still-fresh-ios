//
//  StartView.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 08/05/2025.
//
import SwiftUI

struct StartView : View {
    @State private var selectedTab = 0
    @State private var showAddScreen = false
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    NavBar()
                    
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

                        EmptyView() // Placeholder for the middle tab
                            .tabItem {
                                Image(systemName: "") // Empty to make room for the + button
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
                }

                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showAddScreen.toggle()
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .font(.system(size: 24))
                                .frame(width: 60, height: 60)
                                .background(Color.black)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .offset(y: -30)
                        Spacer()
                    }
                }
            }
        }
    }
}
#Preview{
    StartView()
}
