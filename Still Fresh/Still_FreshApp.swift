//
//  Still_FreshApp.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 26/04/2025.
//

import SwiftUI
import UIKit
import UserNotifications

@main
struct Still_FreshApp: App {
    private let notificationDelegate = NotificationDelegate() // Create an instance of the delegate

    init() {
        UIView.appearance().overrideUserInterfaceStyle = .light
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }
    
    var body: some Scene {
        WindowGroup {
            if SupaClient.auth.currentUser != nil {
                StartView()
            } else {
                LoginView()
            }
//            StartView()
//                .preferredColorScheme(.light)
        }
    }
}
