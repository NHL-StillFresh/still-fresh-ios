//
//  BasketSectionHeader.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 05/06/2025.
//

enum BasketSectionHeader: Comparable {
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
    
    private var sortIndex: Int {
        switch self {
        case .today: return 0
        case .tomorrow: return 1
        case .later: return 2
        }
    }
    
    static func < (lhs: BasketSectionHeader, rhs: BasketSectionHeader) -> Bool {
        return lhs.sortIndex < rhs.sortIndex
    }
}
