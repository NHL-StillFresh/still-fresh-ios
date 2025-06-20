import SwiftUI

enum AlertType {
    case error
    case signOut
}

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var userState: UserStateModel
    @AppStorage("notificationsEnabled") private var notifications = false
    @AppStorage("selectedHouseId") var storedHouseId: String?
    @State private var darkMode = false
    @State private var expiryNotificationDays = 3
    @State private var selectedUnit = "Days"
    @State private var showEditProfile = false
    @State private var showErrorMessage = false
    @State private var alertType: AlertType = .error
    @State private var showCheckProductsView = false
    @State private var showWrapped = false
    
    @StateObject private var wrappedHandler = WrappedAnalyticsHandler()
    
    private let tealColor = Color(red: 122/255, green: 190/255, blue: 203/255)
    private let units = ["Days", "Weeks"]
    
    var body: some View {
        NavigationView {
            List {
                // Profile Section
                Section {
                    HStack(spacing: 15) {
                        ZStack {
                            AsyncImage(url: userState.userProfile?.image) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 70, height: 40)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle().stroke(Color.teal, lineWidth: 2)
                                    )
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 40, height: 40)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(userState.userProfile?.firstName ?? "User") \(userState.userProfile?.lastName ?? "")")
                                .font(.system(size: 20, weight: .bold))
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
                            ProfileEditView(userState: userState)
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
                
                // Still Fresh Wrapped Section
                Section {
                    if wrappedHandler.isGenerating {
                        HStack {
                            Spacer()
                            VStack(spacing: 12) {
                                ProgressView()
                                    .scaleEffect(1.2)
                                    .tint(tealColor)
                                Text("Generating your year in review...")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 40)
                            Spacer()
                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                    } else {
                        WrappedCard(
                            wrappedData: wrappedHandler.currentWrappedData,
                            onTap: {
                                showWrapped = true
                            }
                        )
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                    }
                } header: {
                    Text("YEAR IN REVIEW")
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
                                storedHouseId = nil
                                userState.invalidateSession()
                            }
                        },
                        secondaryButton: .cancel()
                    );

                }
                
            }
        }
        .sheet(isPresented: $showWrapped) {
            WrappedView(wrappedData: wrappedHandler.currentWrappedData)
        }
        .onAppear {
            // Generate real wrapped data from user's actual data
            Task {
                await generateRealWrappedData()
            }
        }
    }
    
    private func generateRealWrappedData() async {
        // Generate wrapped data from real Supabase data
        await wrappedHandler.generateWrapped()
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
