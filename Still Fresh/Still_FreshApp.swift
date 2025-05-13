//
//  Still_FreshApp.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 26/04/2025.
//

import SwiftUI
import UIKit

@main
struct Still_FreshApp: App {
    init() {
        // Force light mode even when device is in dark mode
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .forEach { windowScene in
                windowScene.windows.forEach { window in
                    window.overrideUserInterfaceStyle = .light
                }
            }
    }
    
    var body: some Scene {
        WindowGroup {
            LoginView()
                .preferredColorScheme(.light)
        }
    }
}
