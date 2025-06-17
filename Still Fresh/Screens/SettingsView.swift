import SwiftUI

enum AlertType {
    case error
    case signOut
}

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var userState: UserStateModel
    @AppStorage("notificationsEnabled") private var notifications = false
    @State private var darkMode = false
    @State private var expiryNotificationDays = 3
    @State private var selectedUnit = "Days"
    @State private var username = "App Tester"
    @State private var email = "apptester@stillfresh.nl"
    @State private var showEditProfile = false
    @State private var showErrorMessage = false
    @State private var alertType: AlertType = .error
    @State private var showCheckProductsView = false
    
    private let tealColor = Color(red: 122/255, green: 190/255, blue: 203/255)
    private let units = ["Days", "Weeks"]
    
    var body: some View {
        NavigationView {
            List {
                // Profile Section
                Section {
                    HStack(spacing: 15) {
                        ZStack {
                            Circle()
                                .fill(tealColor.opacity(0.2))
                                .frame(width: 70, height: 70)
                            
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(tealColor)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(userState.userProfile?.firstName ?? "User")
                                .font(.system(size: 20, weight: .bold))
                            
                            Text(email)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showEditProfile = true
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(tealColor)
                                .font(.system(size: 18))
                                .padding(8)
                                .background(tealColor.opacity(0.2))
                                .clipShape(Circle())
                        }
                        .sheet(isPresented: $showEditProfile) {
                            ProfileEditView(username: $username, email: $email)
                        }
                    }
                    .padding(.vertical, 6)
                } header: {
                    Text("PROFILE")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                // Notifications & Preferences
                Section {
                    Toggle(isOn: $notifications) {
                        SettingRow(icon: "bell.fill", iconColor: .orange, title: "Notifications")
                    }
                    .tint(tealColor)
                    .onChange(of: notifications) {
                        if notifications {
                            requestNotificationPermission { granted in
                                if granted {
                                    sendTimeNotification(
                                        title: "Setting successfully changed!",
                                        body: "Notifications are now enabled",
                                        after: 1
                                    )
                                } else {
                                    print("Notification permission not granted.")
                                }
                            }
                        }
                        
                    }
                    NavigationLink {
                                                HouseDashboard()


                                            } label: {


                                                SettingRow(icon: "house.fill", iconColor: tealColor, title: "House Dashboard")


                                            }
        
                    
                } header: {
                    Text("PREFERENCES")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                // App Info & Support
                Section {
                    NavigationLink {
                        AboutView()
                    } label: {
                        SettingRow(icon: "info.circle.fill", iconColor: tealColor, title: "About Still Fresh")
                    }
                    
                } header: {
                    Text("INFO & SUPPORT")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                // Sign Out
                Section {
                    Button(action: {
                        alertType = .signOut
                        showErrorMessage = true
                    }) {
                        HStack {
                            Spacer()
                            Text("Sign Out")
                                .foregroundColor(.red)
                                .font(.system(size: 16, weight: .medium))
                            Spacer()
                        }
                    }
                }
                #if DEBUG
                Section {
                    Button(action: {
                        userState.isLoading = true
                    }) {
                        HStack {
                            Spacer()
                            Text("Check Loader (DEBUG ONLY)")
                                .foregroundColor(.red)
                                .font(.system(size: 16, weight: .medium))
                            Spacer()
                        }
                    }

                }
                #endif
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                            .font(.system(size: 16, weight: .medium))
                    }
                }
            }
            .alert(isPresented: $showErrorMessage) {
                switch alertType {
                case .error:
                    Alert(title: Text("Error"),
                                      message: Text("An error occured"),
                                      dismissButton: .default(Text("Dismiss")))
                case .signOut:
                    Alert(
                        title: Text("Sign out?"),
                        message: Text("Are you sure you want to sign out?"),
                        primaryButton: .destructive(Text("Sign Out")) {
                            Task {
                                try? await SupaClient.auth.signOut()
                                userState.invalidateSession()
                            }
                        },
                        secondaryButton: .cancel()
                    );

                }
                
            }
        }
    }
}

struct SettingRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .font(.system(size: 14))
                .frame(width: 28, height: 28)
                .background(iconColor)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            
            Text(title)
                .font(.system(size: 16))
        }
    }
}

#Preview {
    SettingsView(userState: UserStateModel())
}
