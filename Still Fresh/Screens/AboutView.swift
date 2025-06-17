import SwiftUI

struct AboutView: View {
    private let tealColor = Color(red: 122/255, green: 190/255, blue: 203/255)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // App Icon and Name
                VStack(spacing: 12) {
                    Image("AppIcon")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    
                    Text("Still Fresh")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Version 1.0.0")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // App Description
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "About")
                    
                    Text("Still Fresh is your smart kitchen companion that helps you reduce food waste and save money. Keep track of your groceries' expiration dates, get timely notifications, and discover recipes to use up ingredients before they spoil.")
                        .font(.body)
                        .lineSpacing(4)
                        .foregroundColor(.primary)
                }
                .padding(.horizontal)
                
                // Features
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Features")
                    
                    VStack(spacing: 12) {
                        FeatureRow(icon: "calendar.badge.clock", title: "Expiry Tracking", description: "Never let food go to waste again")
                        FeatureRow(icon: "bell.fill", title: "Smart Notifications", description: "Get reminded before items expire")
                        FeatureRow(icon: "camera.fill", title: "Receipt Scanning", description: "Add products by scanning receipts")
                        FeatureRow(icon: "magnifyingglass", title: "Product Search", description: "Easily find and add products")
                        FeatureRow(icon: "book.fill", title: "Recipe Suggestions", description: "Discover recipes with your ingredients")
                    }
                }
                .padding(.horizontal)
                // Authors/Team
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Development Team")
                    
                    VStack(spacing: 12) {
                        AuthorRow(name: "Jesse van der Voet", role: "Developer")
                        AuthorRow(name: "Gideon Dijkhuis", role: "Developer")
                        AuthorRow(name: "Elmedin Arifi", role: "Developer")
                        AuthorRow(name: "Bram Huiskes", role: "Developer")
                    }
                }
                .padding(.horizontal)
        
                
                // Copyright
                VStack(spacing: 8) {
                    Text("© 2025 Still Fresh")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    Text("Made with ❤️ to reduce food waste")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SectionHeader: View {
    let title: String
    private let tealColor = Color(red: 122/255, green: 190/255, blue: 203/255)
    
    var body: some View {
        Text(title)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(tealColor)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    private let tealColor = Color(red: 122/255, green: 190/255, blue: 203/255)
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(tealColor)
                .font(.system(size: 16))
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct AuthorRow: View {
    let name: String
    let role: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .foregroundColor(.gray)
                .font(.system(size: 20))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(role)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct ContactRow: View {
    let icon: String
    let text: String
    private let tealColor = Color(red: 122/255, green: 190/255, blue: 203/255)
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(tealColor)
                .font(.system(size: 14))
                .frame(width: 20, height: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

#Preview {
    NavigationView {
        AboutView()
    }
} 