import SwiftUI

struct NotificationsView: View {
    // State variables
    @State private var selectedFilter: NotificationFilter = .all
    @State private var selectedAlert: AlertItem?
    @State private var showDetailView = false
    
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
                                        iconColor: .red,
                                        onTap: {
                                            selectedAlert = alert
                                            showDetailView = true
                                        }
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
                                        iconColor: .orange,
                                        onTap: {
                                            selectedAlert = alert
                                            showDetailView = true
                                        }
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
                                        iconColor: .yellow,
                                        onTap: {
                                            selectedAlert = alert
                                            showDetailView = true
                                        }
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
                                        iconColor: lightTealColor,
                                        onTap: {
                                            selectedAlert = alert
                                            showDetailView = true
                                        }
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
        .sheet(isPresented: $showDetailView) {
            if let selectedAlert = selectedAlert {
                AlertDetailView(alert: selectedAlert)
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
    let onTap: () -> Void
    @State private var isPressed = false
    
    // Extract emoji from title for enhanced display
    private var emoji: String {
        let title = alert.title
        if let firstChar = title.first, firstChar.isEmoji {
            return String(firstChar)
        }
        return ""
    }
    
    private var cleanTitle: String {
        let title = alert.title
        if let firstChar = title.first, firstChar.isEmoji {
            return String(title.dropFirst()).trimmingCharacters(in: .whitespaces)
        }
        return title
    }
    
    private var priorityColor: Color {
        if !alert.isRead {
            switch iconColor {
            case .red: return .red
            case .orange: return .orange
            default: return Color(red: 122/255, green: 190/255, blue: 203/255)
            }
        }
        return .gray
    }
    
    var body: some View {
        Button(action: {
            onTap()
        }) {
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    // Enhanced icon with emoji overlay
                    ZStack {
                        Circle()
                            .fill(iconColor.opacity(0.12))
                            .frame(width: 56, height: 56)
                        
                        if !emoji.isEmpty {
                            Text(emoji)
                                .font(.system(size: 24))
                        } else {
                            Image(systemName: icon)
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(iconColor)
                        }
                    }
                    
                    // Content with enhanced typography
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(cleanTitle)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(alert.isRead ? .secondary : .primary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                                
                                Text(alert.timeAgo)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(priorityColor)
                            }
                            
                            Spacer()
                            
                            // Priority indicator with animation
                            if !alert.isRead {
                                ZStack {
                                    Circle()
                                        .fill(priorityColor.opacity(0.2))
                                        .frame(width: 20, height: 20)
                                    
                                    Circle()
                                        .fill(priorityColor)
                                        .frame(width: 8, height: 8)
                                }
                            }
                        }
                        
                        Text(alert.message)
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(20)
                
                // Subtle bottom border for visual separation
                if !alert.isRead {
                    Rectangle()
                        .fill(priorityColor.opacity(0.1))
                        .frame(height: 1)
                        .padding(.horizontal, 20)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
                    .shadow(color: Color.black.opacity(0.08), radius: 1, x: 0, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        alert.isRead ? 
                        Color.clear : 
                        priorityColor.opacity(0.15),
                        lineWidth: 1
                    )
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.15), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents {
            withAnimation(.easeOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = false
            }
        }
    }
}

// Extension to check if a character is an emoji
extension Character {
    var isEmoji: Bool {
        guard let scalar = unicodeScalars.first else { return false }
        return scalar.properties.isEmoji && (scalar.value > 0x238C || unicodeScalars.count > 1)
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

// Comprehensive Alert Detail View
struct AlertDetailView: View {
    let alert: AlertItem
    @Environment(\.dismiss) private var dismiss
    
    // Colors
    private let tealColor = Color(red: 0.04, green: 0.29, blue: 0.29)
    private let lightTealColor = Color(red: 122/255, green: 190/255, blue: 203/255)
    
    // Extract emoji from title
    private var emoji: String {
        let title = alert.title
        if let firstChar = title.first, firstChar.isEmoji {
            return String(firstChar)
        }
        return ""
    }
    
    private var cleanTitle: String {
        let title = alert.title
        if let firstChar = title.first, firstChar.isEmoji {
            return String(title.dropFirst()).trimmingCharacters(in: .whitespaces)
        }
        return title
    }
    
    // Get alert type for dynamic content
    private var alertType: AlertType {
        switch alert.id {
        case 1...4: return .expiry
        case 5...7: return .stock
        case 8...11: return .tips
        default: return .updates
        }
    }
    
    enum AlertType {
        case expiry, stock, tips, updates
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Hero Section
                    heroSection
                    
                    // Main Content
                    VStack(spacing: 24) {
                        // Primary Action Section
                        primaryActionSection
                        
                        // Dynamic Content Based on Alert Type
                        switch alertType {
                        case .expiry:
                            expirySpecificContent
                        case .stock:
                            stockSpecificContent
                        case .tips:
                            tipsSpecificContent
                        case .updates:
                            updatesSpecificContent
                        }
                        
                        // AI Insights Section
                        aiInsightsSection
                        
                        // Quick Actions
                        quickActionsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(tealColor)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Hero Section
    private var heroSection: some View {
        VStack(spacing: 16) {
            // Large Emoji/Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [lightTealColor.opacity(0.2), lightTealColor.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                if !emoji.isEmpty {
                    Text(emoji)
                        .font(.system(size: 48))
                } else {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundColor(lightTealColor)
                }
            }
            
            // Title and Description
            VStack(spacing: 8) {
                Text(cleanTitle)
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                Text(alert.message)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                
                Text(alert.timeAgo)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(lightTealColor)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 20)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Primary Action Section
    private var primaryActionSection: some View {
        VStack(spacing: 16) {
            Button(action: {
                // Primary action
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18, weight: .medium))
                    
                    Text(getPrimaryActionText())
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [tealColor, lightTealColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .shadow(color: tealColor.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            
            if alertType == .expiry {
                Button(action: {
                    // Secondary action
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 16))
                        Text("Remind me in 2 hours")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(tealColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(tealColor.opacity(0.1))
                    )
                }
            }
        }
        .padding(.top, 16)
    }
    
    // MARK: - Expiry Specific Content
    private var expirySpecificContent: some View {
        VStack(spacing: 20) {
            // Recipe Suggestions
            SectionCard(
                title: "Recipe Suggestions",
                icon: "book.fill",
                iconColor: .orange
            ) {
                VStack(spacing: 12) {
                    RecipeRow(name: "Green Smoothie Bowl", time: "5 min", difficulty: "Easy")
                    RecipeRow(name: "Spinach & Feta Wrap", time: "10 min", difficulty: "Easy")
                    RecipeRow(name: "Quick Sautéed Spinach", time: "8 min", difficulty: "Easy")
                }
            }
            
            // Storage Tips
            SectionCard(
                title: "Storage Tips",
                icon: "archivebox.fill",
                iconColor: .blue
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    TipRow(
                        icon: "thermometer.medium",
                        text: "Store in refrigerator at 32-40°F",
                        color: .blue
                    )
                    TipRow(
                        icon: "drop.fill",
                        text: "Keep in slightly damp paper towel",
                        color: .cyan
                    )
                    TipRow(
                        icon: "wind",
                        text: "Ensure good air circulation",
                        color: .mint
                    )
                }
            }
        }
    }
    
    // MARK: - Stock Specific Content
    private var stockSpecificContent: some View {
        VStack(spacing: 20) {
            // Shopping List
            SectionCard(
                title: "Add to Shopping List",
                icon: "cart.fill",
                iconColor: .green
            ) {
                VStack(spacing: 12) {
                    ShoppingItem(name: "Organic Milk (64 fl oz)", store: "Whole Foods", price: "$4.99")
                    ShoppingItem(name: "Oat Milk Alternative", store: "Target", price: "$3.49")
                    ShoppingItem(name: "Lactose-Free Milk", store: "Safeway", price: "$4.29")
                }
            }
            
            // Usage Patterns
            SectionCard(
                title: "Your Usage Pattern",
                icon: "chart.line.uptrend.xyaxis",
                iconColor: .purple
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    StatRow(label: "Weekly consumption", value: "2.1 gallons")
                    StatRow(label: "Avg. purchase frequency", value: "Every 4 days")
                    StatRow(label: "Preferred brands", value: "Organic Valley, Horizon")
                    StatRow(label: "Best price found", value: "$3.99 at Costco")
                }
            }
        }
    }
    
    // MARK: - Tips Specific Content
    private var tipsSpecificContent: some View {
        VStack(spacing: 20) {
            // Related Tips
            SectionCard(
                title: "More Food Hacks",
                icon: "lightbulb.fill",
                iconColor: .yellow
            ) {
                VStack(spacing: 12) {
                    TipRow(
                        icon: "snowflake",
                        text: "Freeze herbs in ice cube trays with water or oil",
                        color: .blue
                    )
                    TipRow(
                        icon: "leaf.fill",
                        text: "Store fresh herbs like flowers in water",
                        color: .green
                    )
                    TipRow(
                        icon: "seal.fill",
                        text: "Use vacuum-sealed bags for longer storage",
                        color: .purple
                    )
                }
            }
            
            // Impact Stats
            SectionCard(
                title: "Your Impact",
                icon: "leaf.arrow.circlepath",
                iconColor: .green
            ) {
                VStack(spacing: 16) {
                    HStack {
                        VStack {
                            Text("2.3 lbs")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.green)
                            Text("Food saved")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text("$18.50")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.blue)
                            Text("Money saved")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text("4.1 kg")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.orange)
                            Text("CO₂ prevented")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Updates Specific Content
    private var updatesSpecificContent: some View {
        VStack(spacing: 20) {
            // What's New
            SectionCard(
                title: "What's New",
                icon: "sparkles",
                iconColor: .purple
            ) {
                VStack(spacing: 12) {
                    FeatureRow(
                        icon: "camera.viewfinder",
                        title: "Enhanced Barcode Scanning",
                        description: "99.2% accuracy with new AI model"
                    )
                    FeatureRow(
                        icon: "brain.head.profile",
                        title: "Smart Expiry Predictions",
                        description: "Learns from your storage conditions"
                    )
                    FeatureRow(
                        icon: "chart.pie.fill",
                        title: "Detailed Analytics",
                        description: "Track your food waste reduction"
                    )
                }
            }
        }
    }
    
    // MARK: - AI Insights Section
    private var aiInsightsSection: some View {
        SectionCard(
            title: "AI Insights",
            icon: "brain.head.profile",
            iconColor: .purple
        ) {
            VStack(alignment: .leading, spacing: 12) {
                InsightRow(
                    icon: "chart.line.uptrend.xyaxis",
                    text: "You typically use 85% of your produce before expiry",
                    color: .green
                )
                InsightRow(
                    icon: "clock.fill",
                    text: "Best time to shop: Tuesday mornings for freshest produce",
                    color: .blue
                )
                InsightRow(
                    icon: "leaf.fill",
                    text: "Switching to organic extends freshness by 1.2 days on average",
                    color: .mint
                )
            }
        }
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(spacing: 16) {
            Text("Quick Actions")
                .font(.system(size: 18, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                // Primary actions row
                HStack(spacing: 12) {
                    QuickActionButton(
                        icon: "bell.slash.fill",
                        title: "Mark as Read",
                        subtitle: "Dismiss notification",
                        color: .gray,
                        isPrimary: true
                    )
                    
                    QuickActionButton(
                        icon: "clock.fill",
                        title: "Snooze",
                        subtitle: "Remind later",
                        color: .orange,
                        isPrimary: true
                    )
                }
                
                // Secondary actions row
                HStack(spacing: 12) {
                    QuickActionButton(
                        icon: "square.and.arrow.up",
                        title: "Share",
                        subtitle: "Send to friends",
                        color: .blue,
                        isPrimary: false
                    )
                    
                    QuickActionButton(
                        icon: "trash.fill",
                        title: "Delete",
                        subtitle: "Remove forever",
                        color: .red,
                        isPrimary: false
                    )
                }
            }
        }
    }
    
    // Helper function to get primary action text
    private func getPrimaryActionText() -> String {
        switch alertType {
        case .expiry:
            return "Mark as Read"
        case .stock:
            return "Add to Shopping List"
        case .tips:
            return "Mark as Helpful"
        case .updates:
            return "Learn More"
        }
    }
}

// MARK: - Supporting Views

struct SectionCard<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    let content: Content
    
    init(title: String, icon: String, iconColor: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 16, weight: .medium))
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            content
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

struct RecipeRow: View {
    let name: String
    let time: String
    let difficulty: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 16, weight: .medium))
                
                HStack(spacing: 8) {
                    Text(time)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Text(difficulty)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(red: 122/255, green: 190/255, blue: 203/255))
            }
        }
        .padding(.vertical, 4)
    }
}

struct TipRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 14, weight: .medium))
                .frame(width: 20)
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct ShoppingItem: View {
    let name: String
    let store: String
    let price: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 16, weight: .medium))
                
                Text(store)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(price)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.green)
        }
        .padding(.vertical, 4)
    }
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color(red: 122/255, green: 190/255, blue: 203/255))
                .font(.system(size: 16, weight: .medium))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct InsightRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 14, weight: .medium))
                .frame(width: 20)
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let isPrimary: Bool
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {}) {
            VStack(spacing: 12) {
                // Icon container with colored background
                ZStack {
                    Circle()
                        .fill(color.opacity(isPrimary ? 0.15 : 0.1))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(color)
                }
                
                // Text content
                VStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: isPrimary ? 110 : 98)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.opacity(isPrimary ? 0.2 : 0.1), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.15), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents {
            withAnimation(.easeOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = false
            }
        }
    }
}

#Preview {
    NotificationsView()
}
