import SwiftUI

struct NotificationsView: View {
    @State private var selectedAlert: AlertModel?
    @StateObject private var alertHandler = AlertHandler()
    @AppStorage("lastAlertSyncDate") private var lastAlertSyncDate: Date?
    
    private let tealColor = Color(red: 0.04, green: 0.29, blue: 0.29)
    private let lightTealColor = Color(red: 122/255, green: 190/255, blue: 203/255)
    
    var body: some View {
        VStack(spacing: 0) {
            if !alertHandler.alerts.isEmpty {
                ScrollView {
                    VStack {
                        Button ("Clear all") {
                            alertHandler.alerts = []
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, 20)
                    
                    LazyVStack(spacing: 12) {
                        ForEach(alertHandler.alerts, id: \.id) { alert in
                            ModernNotificationCard(
                                alert: alert,
                                icon: "exclamationmark.triangle.fill",
                                iconColor: .red,
                                onTap: {
                                    alertHandler.alerts.removeAll(where: { $0.id == alert.id })
                                    alertHandler.alerts.append(AlertModel(id: alert.id, title: alert.title, message: alert.message, timeAgo: alert.timeAgo, isRead: true))
                                }
                            )
                        }
                        
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
                        
                        Text("You're all caught up!")
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
        .onAppear {
            Task {
                do {
                    if let syncDate = lastAlertSyncDate, Calendar.current.isDateInToday(syncDate) {
                        return
                    }
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd-MM-yyyy"
                    
                    let foodItems: [FoodItem] = try await BasketHandler.getBasketProducts()
                    
                    var alertId = 0
                    for foodItem in foodItems {
                        if foodItem.daysUntilExpiry == 1 {
                            alertHandler.alerts.append(
                                AlertModel(
                                    id: Int(Date().timeIntervalSince1970) + alertId,
                                    title: "Product Expiring Soon",
                                    message: "\(foodItem.name) will expire in 1 day",
                                    timeAgo: dateFormatter.string(from: Date()),
                                    isRead: false
                                )
                            )
                            alertId += 1
                        }
                    }
                    lastAlertSyncDate = Date()
                    
                } catch {
                    print("Error loading products: \(error)")
                }
            }
        }
    }

}

struct ModernNotificationCard: View {
    let alert: AlertModel
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

#Preview {
    NotificationsView()
}
