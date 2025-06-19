//
//  AlertHandler.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 10/06/2025.
//

import SwiftUI

class AlertHandler: ObservableObject {
    @Published var alerts: [AlertModel] {
        didSet {
            saveAlerts()
        }
    }
    
    private let key = "basketAlerts"

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([AlertModel].self, from: data) {
            self.alerts = decoded
        } else {
            self.alerts = []
        }
    }

    private func saveAlerts() {
        if let encoded = try? JSONEncoder().encode(alerts) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}
