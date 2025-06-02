//
//  FoodCategory.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 27/05/2025.
//


// Food Categories
enum FoodCategory: String, CaseIterable {
    case fruits = "Fruits"
    case vegetables = "Vegetables"
    case grains = "Grains"
    case proteins = "Proteins"
    case dairy = "Dairy"
    case fatsAndOils = "Fats and Oils"
    case herbsAndSpices = "Herbs and Spices"
    case condimentsAndSauces = "Condiments and Sauces"
    case sweetsAndSnackes = "Sweets and Snackes"
    case drinks = "Drinks"
    
    var name: String {
        return self.rawValue
    }
    
    var iconName: String {
        switch self {
            case .fruits: return "apple.logo"
            case .vegetables: return "carrot.fill"
            case .grains : return "bag.fill"
            case .proteins: return "person.fill"
            case .dairy: return "cup.and.saucer.fill"
            case .fatsAndOils: return "drop.fill"
            case .herbsAndSpices: return "flame.fill"
            case .condimentsAndSauces: return "wineglass.fill"
            case .sweetsAndSnackes: return "popcorn.fill"
            case .drinks: return "waterbottle.fill"
        }
    }
}
