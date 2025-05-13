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
                NavBar()
                BottomNavBar(selectedTab: $selectedTab)
            }
        }
    }
}

#Preview {
    StartView()
}
