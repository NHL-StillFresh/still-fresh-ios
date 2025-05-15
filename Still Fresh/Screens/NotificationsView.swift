import SwiftUI

struct NotificationsView: View {
    // State variables
    @State private var selectedFilter: NotificationFilter = .all
    
    // Colors - using the app's consistent teal color
    private let tealColor = Color(red: 0.04, green: 0.29, blue: 0.29)
    private let lightTealColor = Color(red: 122/255, green: 190/255, blue: 203/255)
    
    var body: some View {
        VStack(spacing: 0) {
            // Content
            ZStack {
                Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading, spacing: 0) {
                    // Page Title
                    HStack {
                        Text("Alerts")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Button(action: {
                            // Mark all as read action
                        }) {
                            Text("Mark All Read")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(tealColor)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.bottom, 8)
                    
                    // Filter Selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(NotificationFilter.allCases, id: \.self) { filter in
                                FilterButton(
                                    title: filter.title,
                                    isSelected: selectedFilter == filter,
                                    action: {
                                        selectedFilter = filter
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 12)
                    }
                    
                    // Alerts List
                    ScrollView {
                        VStack(spacing: 16) {
                            // Expiry Alerts
                            if selectedFilter == .all || selectedFilter == .expiry {
                                if !expiryAlerts.isEmpty {
                                    AlertSectionView(
                                        title: "EXPIRATION ALERTS",
                                        alerts: expiryAlerts,
                                        icon: "exclamationmark.triangle.fill",
                                        iconColor: .red
                                    )
                                }
                            }
                            
                            // Low Stock Alerts
                            if selectedFilter == .all || selectedFilter == .stock {
                                if !stockAlerts.isEmpty {
                                    AlertSectionView(
                                        title: "LOW STOCK ALERTS",
                                        alerts: stockAlerts,
                                        icon: "bag.fill", 
                                        iconColor: .orange
                                    )
                                }
                            }
                            
                            // Tips
                            if selectedFilter == .all || selectedFilter == .tips {
                                if !tipAlerts.isEmpty {
                                    AlertSectionView(
                                        title: "TIPS & ANNOUNCEMENTS",
                                        alerts: tipAlerts,
                                        icon: "lightbulb.fill",
                                        iconColor: .yellow
                                    )
                                }
                            }
                            
                            // App Updates
                            if selectedFilter == .all || selectedFilter == .updates {
                                if !updateAlerts.isEmpty {
                                    AlertSectionView(
                                        title: "APP UPDATES",
                                        alerts: updateAlerts,
                                        icon: "bell.fill",
                                        iconColor: lightTealColor
                                    )
                                }
                            }
                            
                            // Show empty state if no alerts match the filter
                            if (selectedFilter == .expiry && expiryAlerts.isEmpty) ||
                               (selectedFilter == .stock && stockAlerts.isEmpty) ||
                               (selectedFilter == .tips && tipAlerts.isEmpty) ||
                               (selectedFilter == .updates && updateAlerts.isEmpty) {
                                VStack(spacing: 16) {
                                    Image(systemName: "bell.slash")
                                        .font(.system(size: 48))
                                        .foregroundColor(Color(UIColor.systemGray3))
                                        .padding(.top, 60)
                                    
                                    Text("No \(selectedFilter.title) alerts")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(Color(UIColor.systemGray))
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    // Sample data
    var expiryAlerts: [AlertItem] = [
        AlertItem(id: 1, title: "Milk expires tomorrow", message: "Your milk will expire in 1 day", timeAgo: "4h ago", isRead: false),
        AlertItem(id: 2, title: "Spinach expires today", message: "Your spinach expires today", timeAgo: "1d ago", isRead: true),
        AlertItem(id: 3, title: "Tomatoes expiring soon", message: "Your tomatoes will expire in 2 days", timeAgo: "2d ago", isRead: true)
    ]
    
    var stockAlerts: [AlertItem] = [
        AlertItem(id: 4, title: "Low on milk", message: "You only have 1 carton left", timeAgo: "6h ago", isRead: false),
        AlertItem(id: 5, title: "Low on eggs", message: "You only have 2 eggs left", timeAgo: "1d ago", isRead: true)
    ]
    
    var tipAlerts: [AlertItem] = [
        AlertItem(id: 6, title: "Weekly meal prep tip", message: "Freezing herbs in olive oil helps preserve freshness", timeAgo: "12h ago", isRead: false),
        AlertItem(id: 7, title: "Weekly food saving tip", message: "Store avocados with apples to speed up ripening", timeAgo: "1w ago", isRead: true)
    ]
    
    var updateAlerts: [AlertItem] = [
        AlertItem(id: 8, title: "App updated to v1.2", message: "New features: improved food recognition and barcode scanning", timeAgo: "3d ago", isRead: true)
    ]
}

// Alert filters
enum NotificationFilter: String, CaseIterable {
    case all
    case expiry
    case stock
    case tips
    case updates
    
    var title: String {
        switch self {
        case .all: return "All"
        case .expiry: return "Expiry"
        case .stock: return "Stock"
        case .tips: return "Tips"
        case .updates: return "Updates"
        }
    }
}

// Alert item model
struct AlertItem {
    let id: Int
    let title: String
    let message: String
    let timeAgo: String
    let isRead: Bool
}

// Filter Button Component
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? .white : Color(red: 0.04, green: 0.29, blue: 0.29))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color(red: 0.04, green: 0.29, blue: 0.29) : Color(UIColor.systemGray6))
                )
        }
    }
}

// Alert Section View
struct AlertSectionView: View {
    let title: String
    let alerts: [AlertItem]
    let icon: String
    let iconColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.leading, 4)
            
            VStack(spacing: 12) {
                ForEach(alerts, id: \.id) { alert in
                    NotificationCell(
                        icon: icon,
                        iconColor: iconColor,
                        title: alert.title,
                        message: alert.message,
                        timeAgo: alert.timeAgo,
                        isRead: alert.isRead
                    )
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

// Notification Cell View
struct NotificationCell: View {
    let icon: String
    let iconColor: Color
    let title: String
    let message: String
    let timeAgo: String
    let isRead: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon
            Image(systemName: icon)
                .foregroundColor(.white)
                .font(.system(size: 14))
                .frame(width: 28, height: 28)
                .background(iconColor)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            
            VStack(alignment: .leading, spacing: 4) {
                // Title
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isRead ? .secondary : .primary)
                
                // Message
                Text(message)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                // Time
                Text(timeAgo)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .padding(.top, 2)
            }
            
            Spacer()
            
            // Unread indicator
            if !isRead {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
    }
}

#Preview {
    NotificationsView()
}
