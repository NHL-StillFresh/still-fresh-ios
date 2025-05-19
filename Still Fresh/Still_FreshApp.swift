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
        UIView.appearance().overrideUserInterfaceStyle = .light
    }
    
    var body: some Scene {
        WindowGroup {
             LoginView()
//            StartView()
//                .preferredColorScheme(.light)
        }
    }
}
