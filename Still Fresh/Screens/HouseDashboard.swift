import SwiftUI
import Supabase

struct HouseDashboard: View {
    @StateObject private var dataManager: HouseDataManager
    private let tealColor = Color(UIColor.systemTeal)
    
    init(dataManager: HouseDataManager = HouseDataManager()) {
        _dataManager = StateObject(wrappedValue: dataManager)
    }
    
    // Sample dropdown menu data
    private let dropdownItems: [DropdownItem] = [
        DropdownItem(
            title: "House Management",
            icon: "house.fill",
            items: [
                DropdownItem(title: "View House Details", icon: "doc.text.fill", items: nil),
                DropdownItem(title: "Edit House Info", icon: "pencil", items: nil),
                DropdownItem(title: "House Settings", icon: "gear", items: nil)
            ]
        ),
        DropdownItem(
            title: "Members",
            icon: "person.3.fill",
            items: [
                DropdownItem(title: "View All Members", icon: "person.2.fill", items: nil),
                DropdownItem(title: "Invite New Member", icon: "person.badge.plus", items: nil),
                DropdownItem(title: "Manage Permissions", icon: "lock.fill", items: nil)
            ]
        ),
        DropdownItem(
            title: "Shopping Lists",
            icon: "cart.fill",
            items: [
                DropdownItem(title: "Current List", icon: "list.bullet", items: nil),
                DropdownItem(title: "Create New List", icon: "plus.circle", items: nil),
                DropdownItem(title: "View History", icon: "clock.fill", items: nil)
            ]
        ),
        DropdownItem(
            title: "Statistics",
            icon: "chart.bar.fill",
            items: nil
        )
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                if dataManager.isLoading {
                    loadingView
                } else if dataManager.showJoinGroupView {
                    joinGroupView
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Animated dropdown menu
                            AnimatedDropdownMenu(title: "House Dashboard Options", items: dropdownItems)
                                .padding(.horizontal, 16)
                                .padding(.top, 8)
                            
                            // Group info card
                            groupInfoCard
                                .padding(.horizontal, 16)
                            
                            // Members section
                            membersSection
                                .padding(.horizontal, 16)
                            
                            // Spacer at bottom for better scrolling experience
                            Spacer(minLength: 40)
                        }
                        .padding(.top, 16)
                    }
                }
            }
            .navigationTitle("House Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                Task {
                    await dataManager.loadGroupData()
                }
            }
            .alert(isPresented: .constant(dataManager.errorMessage != nil)) {
                Alert(
                    title: Text("Error"),
                    message: Text(dataManager.errorMessage ?? "Unknown error"),
                    dismissButton: .default(Text("OK")) {
                        dataManager.errorMessage = nil
                    }
                )
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            ProgressView()
                .scaleEffect(1.2)
                .tint(tealColor)
            
            VStack(spacing: 8) {
                Text("Loading House Data")
                    .font(.headline)
                
                Text("Please wait while we fetch your house information")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
    
    private var joinGroupView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "house.circle.fill")
                    .font(.system(size: 70))
                    .foregroundColor(tealColor)
                
                Text("Join a House")
                    .font(.system(size: 24, weight: .bold))
                
                Text("Enter a house ID to join an existing group")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            VStack(spacing: 16) {
                TextField("House ID", text: $dataManager.joinGroupId)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal, 32)
                
                Button(action: {
                    dataManager.joinGroup()
                }) {
                    HStack(spacing: 12) {
                        if dataManager.isJoiningGroup {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .tint(.white)
                        } else {
                            Text("Join House")
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(tealColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 32)
                }
                .disabled(dataManager.joinGroupId.isEmpty || dataManager.isJoiningGroup)
                .opacity(dataManager.joinGroupId.isEmpty || dataManager.isJoiningGroup ? 0.6 : 1)
            }
            
            Spacer()
        }
        .alert("Success", isPresented: $dataManager.joinSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You've successfully joined the house!")
        }
    }
    
    private var groupInfoCard: some View {
        VStack(spacing: 16) {
            // Group name and info
            VStack(spacing: 8) {
                Text(dataManager.house?.houseName ?? "My House Group")
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center)
                
                if let houseId = dataManager.house?.houseId {
                    Text("House ID: \(houseId)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("\(dataManager.members.count) members")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Group actions
            HStack(spacing: 20) {
                Button(action: {
                    // Add action for inviting members
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 20))
                        Text("Invite")
                            .font(.system(size: 14))
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Button(action: {
                    // Add action for group settings
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "gear")
                            .font(.system(size: 20))
                        Text("Settings")
                            .font(.system(size: 14))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .foregroundColor(tealColor)
            .padding(.top, 8)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
        )
    }
    
    private var membersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            Text("Members")
                .font(.system(size: 20, weight: .bold))
                .padding(.leading, 4)
            
            // Members list
            VStack(spacing: 0) {
                ForEach(dataManager.members, id: \.user_id) { member in
                    MemberRow(member: member)
                    
                    if member.user_id != dataManager.members.last?.user_id {
                        Divider()
                            .padding(.leading, 68)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
        }
    }
    
    struct MemberRow: View {
        let member: ProfileModel
        
        var fullName: String {
            return "\(member.profile_first_name) \(member.profile_last_name)"
        }
        
        var body: some View {
            HStack(spacing: 16) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color(.systemGray5))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Text(member.profile_first_name.prefix(1).uppercased())
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.gray)
                        )
                }
                
                // Member details
                VStack(alignment: .leading, spacing: 4) {
                    Text(fullName)
                        .font(.system(size: 16, weight: .medium))
                    
                    Text("Member ID: \(member.user_id.prefix(8))")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Action button
                Button(action: {
                    // Add action for member options
                }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(Color(.systemGray6))
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}

// Preview-specific data manager for testing
class PreviewHouseDataManager: HouseDataManager {
    override func loadGroupData() async {
        print("🏠 PreviewHouseDataManager: Using preview data")
        // Set up mock data for preview
        await MainActor.run {
            self.house = HouseModel(
                houseAddress: "123 Preview St",
                houseName: "Preview House",
                houseImage: "house.fill",
                createdAt: "2025-05-01",
                updatedAt: "2025-05-29",
                houseId: "preview-house-id"
            )
            
            self.members = [
                ProfileModel(
                    user_id: "user1",
                    profile_first_name: "John",
                    profile_last_name: "Doe",
                    created_at: nil,
                    updated_at: nil
                ),
                ProfileModel(
                    user_id: "user2",
                    profile_first_name: "Jane",
                    profile_last_name: "Smith",
                    created_at: nil,
                    updated_at: nil
                )
            ]
            
            self.isLoading = false
            self.showJoinGroupView = false
        }
    }
}

#Preview {
    HouseDashboard()
}
