import SwiftUI

struct NotificationsView: View {
    // State variables
    @State private var selectedFilter: NotificationFilter = .all
    
    // Colors - using the app's consistent teal color
    private let tealColor = Color(red: 0.04, green: 0.29, blue: 0.29)
    private let lightTealColor = Color(red: 122/255, green: 190/255, blue: 203/255)
    
    var body: some View {
        VStack(spacing: 0) {
            // Filter Selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(NotificationFilter.allCases, id: \.self) { filter in
                        FilterButton(
                            title: filter.title,
                            isSelected: selectedFilter == filter,
                            action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedFilter = filter
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color(.systemBackground))
            
            // Content
            if hasAnyAlerts {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        // Expiry Alerts
                        if selectedFilter == .all || selectedFilter == .expiry {
                            if !expiryAlerts.isEmpty {
                                ForEach(expiryAlerts, id: \.id) { alert in
                                    ModernNotificationCard(
                                        alert: alert,
                                        icon: "exclamationmark.triangle.fill",
                                        iconColor: .red
                                    )
                                }
                            }
                        }
                        
                        // Low Stock Alerts
                        if selectedFilter == .all || selectedFilter == .stock {
                            if !stockAlerts.isEmpty {
                                ForEach(stockAlerts, id: \.id) { alert in
                                    ModernNotificationCard(
                                        alert: alert,
                                        icon: "bag.fill",
                                        iconColor: .orange
                                    )
                                }
                            }
                        }
                        
                        // Tips
                        if selectedFilter == .all || selectedFilter == .tips {
                            if !tipAlerts.isEmpty {
                                ForEach(tipAlerts, id: \.id) { alert in
                                    ModernNotificationCard(
                                        alert: alert,
                                        icon: "lightbulb.fill",
                                        iconColor: .yellow
                                    )
                                }
                            }
                        }
                        
                        // App Updates
                        if selectedFilter == .all || selectedFilter == .updates {
                            if !updateAlerts.isEmpty {
                                ForEach(updateAlerts, id: \.id) { alert in
                                    ModernNotificationCard(
                                        alert: alert,
                                        icon: "bell.fill",
                                        iconColor: lightTealColor
                                    )
                                }
                            }
                        }
                        
                        // Bottom padding to account for tab bar
                        Color.clear.frame(height: 80)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            } else {
                // Empty state
                VStack(spacing: 24) {
                    Spacer()
                    
                    Image(systemName: "bell.slash")
                        .font(.system(size: 50))
                        .foregroundColor(lightTealColor.opacity(0.6))
                    
                    VStack(spacing: 8) {
                        Text("No notifications")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("You're all caught up! Check back later for updates.")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    // Computed property to check if we have alerts based on current filter
    private var hasAnyAlerts: Bool {
        switch selectedFilter {
        case .all:
            return !expiryAlerts.isEmpty || !stockAlerts.isEmpty || !tipAlerts.isEmpty || !updateAlerts.isEmpty
        case .expiry:
            return !expiryAlerts.isEmpty
        case .stock:
            return !stockAlerts.isEmpty
        case .tips:
            return !tipAlerts.isEmpty
        case .updates:
            return !updateAlerts.isEmpty
        }
    }
    
    // Sample data
    var expiryAlerts: [AlertItem] = [
        AlertItem(id: 1, title: "🥛 Milk expires today!", message: "Your organic milk expires today. Use it in a smoothie or cereal before it goes bad.", timeAgo: "2h ago", isRead: false),
        AlertItem(id: 2, title: "🥬 Spinach expires tomorrow", message: "Fresh spinach will expire in 1 day. Perfect time to make a healthy salad or green smoothie.", timeAgo: "4h ago", isRead: false),
        AlertItem(id: 3, title: "🍅 Cherry tomatoes expiring soon", message: "Your cherry tomatoes will expire in 2 days. Great for pasta or a caprese salad!", timeAgo: "1d ago", isRead: true),
        AlertItem(id: 4, title: "🧀 Cheddar cheese expires in 3 days", message: "Time to use that cheddar! Perfect for grilled cheese or mac and cheese.", timeAgo: "1d ago", isRead: true)
    ]
    
    var stockAlerts: [AlertItem] = [
        AlertItem(id: 5, title: "🥛 Running low on milk", message: "You only have 1 carton left. Don't forget to add it to your shopping list!", timeAgo: "6h ago", isRead: false),
        AlertItem(id: 6, title: "🥚 Almost out of eggs", message: "Only 3 eggs remaining. Time to restock for your weekend breakfast!", timeAgo: "8h ago", isRead: false),
        AlertItem(id: 7, title: "🍞 Bread supply is low", message: "You're down to your last few slices. Perfect time to grab a fresh loaf.", timeAgo: "1d ago", isRead: true)
    ]
    
    var tipAlerts: [AlertItem] = [
        AlertItem(id: 8, title: "💡 Smart Storage Tip", message: "Store your bananas separately from other fruits to prevent them from ripening too quickly. This extends freshness by 2-3 days!", timeAgo: "3h ago", isRead: false),
        AlertItem(id: 9, title: "🧊 Freezer Hack Discovered", message: "Did you know? You can freeze fresh herbs in olive oil ice cube trays. They'll last 6 months and add instant flavor to dishes!", timeAgo: "1d ago", isRead: false),
        AlertItem(id: 10, title: "📱 AI Insight", message: "Based on your shopping patterns, you typically buy milk every 4 days. Consider buying organic milk which lasts longer.", timeAgo: "2d ago", isRead: true),
        AlertItem(id: 11, title: "🌱 Sustainability Tip", message: "You've prevented 2.3 lbs of food waste this month! Keep it up - every bit helps the environment.", timeAgo: "3d ago", isRead: true)
    ]
    
    var updateAlerts: [AlertItem] = [
        AlertItem(id: 12, title: "✨ New AI Features Available", message: "Enhanced barcode scanning with 99.2% accuracy and smart expiry predictions are now live!", timeAgo: "2d ago", isRead: false),
        AlertItem(id: 13, title: "📊 Weekly Report Ready", message: "Your personalized food waste report is ready! See how much you've saved and discover new tips.", timeAgo: "1w ago", isRead: true)
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

// Modern Filter Button Component
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? .white : Color(red: 0.04, green: 0.29, blue: 0.29))
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(isSelected ? Color(red: 0.04, green: 0.29, blue: 0.29) : Color(.systemGray6))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Modern Notification Card
struct ModernNotificationCard: View {
    let alert: AlertItem
    let icon: String
    let iconColor: Color
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Handle notification tap
        }) {
            HStack(spacing: 16) {
                // Icon with circular background
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(iconColor)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(alert.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(alert.isRead ? .secondary : .primary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text(alert.timeAgo)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Text(alert.message)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                // Unread indicator
                VStack {
                    if !alert.isRead {
                        Circle()
                            .fill(Color(red: 122/255, green: 190/255, blue: 203/255))
                            .frame(width: 8, height: 8)
                    }
                    Spacer()
                }
                .frame(height: 48)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents {
            isPressed = true
        } onRelease: {
            isPressed = false
        }
    }
}

// Custom press gesture extension for better control
extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    onPress()
                }
                .onEnded { _ in
                    onRelease()
                }
        )
    }
}

#Preview {
    NotificationsView()
}
