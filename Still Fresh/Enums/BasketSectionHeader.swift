//
//  BasketSectionHeader.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 05/06/2025.
//

enum BasketSectionHeader {
    case today
    case tomorrow
    case later
    
    var description : String {
        switch self {
        // Use Internationalization, as appropriate.
        case .today: return "Today"
        case .tomorrow: return "Tomorrow"
        case .later: return "Later"
        }
      }
}
