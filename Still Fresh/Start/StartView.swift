//
//  StartView.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 08/05/2025.
//
import SwiftUI

struct StartView : View {
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Show appropriate NavBar based on the selected tab
                if selectedTab == 0 {
                    HomeNavBar()
                } else {
                    TitleNavBar(title: tabTitle(for: selectedTab))
                }
                
                // Use the existing BottomNavBar component
                BottomNavBar(selectedTab: $selectedTab)
            }
        }
        .navigationBarHidden(true)
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
}

#Preview {
    StartView()
}
