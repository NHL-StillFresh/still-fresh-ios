//
//  SearchResultItem.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 03/06/2025.
//

// Search Result Item View

import SwiftUI

struct SearchResultItem: View {
    var recentSearchesHandler = RecentSearchesHandler()
    let item: FoodItem
    var showExpiryDate = true
    var extraFunction: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 16) {
            // Food icon with background
            if (item.image != nil) {
                AsyncImage(url: URL(string: item.image!)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ZStack {
                        Circle()
                            .fill(bgColorForItem)
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: symbolNameForItem)
                            .font(.system(size: 26))
                            .foregroundColor(bgColorForItem.opacity(1.5))
                    }
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                
            } else {
                ZStack {
                    Circle()
                        .fill(bgColorForItem)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: symbolNameForItem)
                        .font(.system(size: 26))
                        .foregroundColor(bgColorForItem.opacity(1.5))
                }
            }
            
            // Item details
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.system(size: 17, weight: .medium))
                
                if (showExpiryDate) {
                    // Expiry indicator
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(expiryColor)
                            .font(.system(size: 12))
                        
                        Text(item.expiryText)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(expiryColor)
                    }
                }
            }
            
            Spacer()
            
            Button(action: {
                var recentSearches = recentSearchesHandler.getRecentSearches()
                
                recentSearches.insert(item.name, at: recentSearches.endIndex)
                
                RecentSearchesHandler().setRecentSearches(recentSearches)
                
                if (extraFunction != nil) {
                    extraFunction?()
                }
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 26))
                    .foregroundColor(Color(UIColor.systemTeal))
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // Background color based on the item
    private var bgColorForItem: Color {
        return Color(red: 122/255, green: 190/255, blue: 203/255).opacity(0.2)
    }
    
    // Symbol based on food type
    private var symbolNameForItem: String {
        return "fork.knife"
    }
    
    // Color based on days until expiry
    private var expiryColor: Color {
        if item.daysUntilExpiry == 0 {
            return .red
        } else if item.daysUntilExpiry <= 2 {
            return .orange
        } else {
            return Color(red: 122/255, green: 190/255, blue: 203/255)
        }
    }
}
