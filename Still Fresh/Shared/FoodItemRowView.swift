//
//  SearchResultItem.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 03/06/2025.
//

// Search Result Item View

import SwiftUI

struct FoodItemRowView: View {
    var recentSearchesHandler = RecentSearchesHandler()
    let item: FoodItem
    var onClickFunction: (() -> Void)? = nil
    var showExpiryDate = true
    var isSearchObject = false
    
    var isEditMode: Bool = false
    var isSelected: Bool = false
    var onToggleSelection: (() -> Void)? = nil
    var buttonIcon: String? = nil
    
    // New properties for swipe-to-delete
    var onDelete: (() -> Void)? = nil
    var showSwipeToDelete: Bool = false
    
    init(
        item: FoodItem,
        onClickFunction: (() -> Void)? = nil,
        showExpiryDate: Bool = true,
        isSearchObject: Bool = false,
        isEditMode: Bool = false,
        isSelected: Bool = false,
        onToggleSelection: (() -> Void)? = nil,
        buttonIcon: String? = nil,
        onDelete: (() -> Void)? = nil,
        showSwipeToDelete: Bool = false
    ) {
        self.item = item
        self.onClickFunction = onClickFunction
        self.showExpiryDate = showExpiryDate
        self.isSearchObject = isSearchObject
        self.isEditMode = isEditMode
        self.isSelected = isSelected
        self.onToggleSelection = onToggleSelection
        self.buttonIcon = buttonIcon
        self.onDelete = onDelete
        self.showSwipeToDelete = showSwipeToDelete
    }
    
    var body: some View {
        Group {
            if showSwipeToDelete && onDelete != nil {
                // SwiftUI List row with swipe actions for iOS native behavior
                swipeableRowContent
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive, action: {
                            onDelete?()
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            } else {
                // Regular row without swipe functionality
                regularRowContent
            }
        }
    }
    
    private var swipeableRowContent: some View {
        HStack(spacing: 16) {
            if isEditMode && onToggleSelection != nil {
                Button(action: onToggleSelection!) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? Color(UIColor.systemTeal) : Color.gray.opacity(0.5))
                }
                .padding(.trailing, 2)
            }
                        
            
            // Food icon with background
            if (item.image != nil) {
                AsyncImage(url: URL(string: item.image!)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(bgColorForItem)
                            .frame(width: 52, height: 52)
                        
                        Image(systemName: symbolNameForItem)
                            .font(.system(size: 26))
                            .foregroundColor(bgColorForItem.opacity(1.5))
                    }
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(bgColorForItem)
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: symbolNameForItem)
                        .font(.system(size: 24))
                        .foregroundColor(bgColorForItem.opacity(2))
                }
            }
            
            // Food details
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(1)
                
                // Expiry date
                if (showExpiryDate) {
                    Text(item.expiryText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(expiryColor)
                }
            }
            
            Spacer()
            
            // Date tag
            if (showExpiryDate) {
                Text(formattedDate)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.gray.opacity(0.1))
                    )
            }
            
            
            Spacer()
            
            if !isEditMode {
                Button(action: {
                    if (isSearchObject) {
                        var recentSearches = recentSearchesHandler.getRecentSearches()
                        
                        recentSearches.insert(item.name, at: recentSearches.endIndex)
                        
                        RecentSearchesHandler().setRecentSearches(recentSearches)
                    }
                    
                    if (onClickFunction != nil) {
                        onClickFunction?()
                    }
                    
                }) {
                    Image(systemName: buttonIcon == nil ? "plus.circle.fill" : buttonIcon!)
                        .font(.system(size: 26))
                        .foregroundColor(Color(UIColor.systemTeal))
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private var regularRowContent: some View {
        HStack(spacing: 16) {
            if isEditMode && onToggleSelection != nil {
                Button(action: onToggleSelection!) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? Color(UIColor.systemTeal) : Color.gray.opacity(0.5))
                }
                .padding(.trailing, 2)
            }
                        
            
            // Food icon with background
            if (item.image != nil) {
                AsyncImage(url: URL(string: item.image!)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(bgColorForItem)
                            .frame(width: 52, height: 52)
                        
                        Image(systemName: symbolNameForItem)
                            .font(.system(size: 26))
                            .foregroundColor(bgColorForItem.opacity(1.5))
                    }
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(bgColorForItem)
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: symbolNameForItem)
                        .font(.system(size: 24))
                        .foregroundColor(bgColorForItem.opacity(2))
                }
            }
            
            // Food details
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(1)
                
                // Expiry date
                if (showExpiryDate) {
                    Text(item.expiryText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(expiryColor)
                }
            }
            
            Spacer()
            
            // Date tag
            if (showExpiryDate) {
                Text(formattedDate)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.gray.opacity(0.1))
                    )
            }
            
            
            Spacer()
            
            Button(action: {
                if (isSearchObject) {
                    var recentSearches = recentSearchesHandler.getRecentSearches()
                    
                    recentSearches.insert(item.name, at: recentSearches.endIndex)
                    
                    RecentSearchesHandler().setRecentSearches(recentSearches)
                }
                
                if (onClickFunction != nil) {
                    onClickFunction?()
                }
                
            }) {
                Image(systemName: buttonIcon == nil ? "plus.circle.fill" : buttonIcon!)
                    .font(.system(size: 26))
                    .foregroundColor(Color(UIColor.systemTeal))
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: item.expiryDate)
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
