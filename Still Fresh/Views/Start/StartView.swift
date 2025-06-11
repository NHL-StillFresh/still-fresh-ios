//
//  StartView.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 08/05/2025.
//
import SwiftUI

struct StartView : View {
    // Used to keep track of user state
    @ObservedObject var userState: UserStateModel
    @AppStorage("notificationsEnabled") private var notifications = false
    
    @State private var selectedTab = 0
    
    // Animation states
    @State private var navBarOpacity = 0.0
    @State private var contentOpacity = 0.0
    @State private var tabBarOpacity = 0.0
    @State private var contentOffset: CGFloat = 30
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Show appropriate NavBar based on the selected tab
                if selectedTab == 0 {
                    HomeNavBar(userState: userState)
                        .opacity(navBarOpacity)
                } else {
                    TitleNavBar(title: tabTitle(for: selectedTab), userState: userState)
                        .opacity(navBarOpacity)
                }
            
                // Use the existing BottomNavBar component
                BottomNavBar(selectedTab: $selectedTab)
                    .opacity(tabBarOpacity)
            }
            .onAppear {
                animateInterfaceElements()
            }
            .onChange(of: selectedTab) {
                // Animate content when tab changes
                withAnimation(.easeOut(duration: 0.2)) {
                    contentOpacity = 0
                    contentOffset = 20
                }
                
                // Delayed animation for the content of the new tab
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.1)) {
                    contentOpacity = 1
                    contentOffset = 0
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            requestNotificationPermission { granted in
                if granted {
                    notifications = true
//                    sendTimeNotification(title: "Welcome to the Still Fresh app!", body: "And now we're gonna spam you with notifications.", after: 10)
                } else {
                    notifications = false
                    print("Notification permission not granted.")
                }
            }
        }
    }
        
    // Helper function to get the title for each tab
    private func tabTitle(for tab: Int) -> String {
        switch tab {
        case 0: return "Home"
        case 1: return "Basket"
        case 3: return "Search"
        case 4: return "Notifications"
        default: return ""
        }
    }
    
    // Sequentially animate all interface elements
    private func animateInterfaceElements() {
        // Animate navigation bar first
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
            navBarOpacity = 1
        }
        
        // Then animate content
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3)) {
            contentOpacity = 1
            contentOffset = 0
        }
        
        // Finally animate tab bar
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.5)) {
            tabBarOpacity = 1
        }
    }
}

#Preview {
    StartView(userState: UserStateModel())
}
