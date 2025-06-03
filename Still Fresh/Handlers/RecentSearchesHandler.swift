//
//  RecentSearchesHandler.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 27/05/2025.
//

import SwiftUI

class RecentSearchesHandler : ObservableObject {
    @AppStorage("recentSearches") private var recentSearchesData: String = "[]"
    
    public func getRecentSearches() -> [String] {
        if let data = recentSearchesData.data(using: .utf8),
            let decoded = try? JSONDecoder().decode([String].self, from: data) {
            return decoded
        }
        return []
    }

    public func setRecentSearches(_ newValue: [String]) {
        if let data = try? JSONEncoder().encode(newValue),
            let jsonString = String(data: data, encoding: .utf8) {
            recentSearchesData = jsonString
        }
    }
}
