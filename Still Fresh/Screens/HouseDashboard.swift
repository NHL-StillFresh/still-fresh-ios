import SwiftUI
import Supabase

struct HouseDashboard: View {
    @StateObject private var groupManager = GroupSelectionManager()
    private let tealColor = Color(UIColor.systemTeal)
    
    var body: some View {
        NavigationView {
            ZStack {
                if groupManager.isLoading {
                    loadingView
                } else if groupManager.selectedGroup == nil {
                    joinGroupView
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Group selection dropdown
                            AnimatedDropdownMenu(
                                title: groupManager.selectedGroup?.groupName ?? "Select Group",
                                items: groupSelectionItems,
                                onSelect: { item in
                                    // Find the group with matching name and select it
                                    if let group = groupManager.userGroups.first(where: { $0.groupName == item.title }) {
                                        groupManager.selectGroup(group.groupId)
                                    }
                                }
                            )
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
            .navigationTitle("Group Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await groupManager.loadUserGroups()
            }
            .alert("Error", isPresented: .constant(groupManager.errorMessage != nil)) {
                Button("OK", role: .cancel) {
                    groupManager.errorMessage = nil
                }
            } message: {
                Text(groupManager.errorMessage ?? "Unknown error")
            }
        }
    }
    
    // Dynamic group selection items
    private var groupSelectionItems: [DropdownItem] {
        groupManager.userGroups.map { group in
            DropdownItem(
                title: group.groupName,
                icon: group.groupId == groupManager.selectedGroupId ? "checkmark.circle.fill" : "circle",
                items: nil
            )
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            ProgressView()
                .scaleEffect(1.2)
                .tint(tealColor)
            
            VStack(spacing: 8) {
                Text("Loading Group Data")
                    .font(.headline)
                
                Text("Please wait while we fetch your group information")
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
                
                Text("Join a Group")
                    .font(.system(size: 24, weight: .bold))
                
                Text("Enter a group ID to join an existing group")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            VStack(spacing: 16) {
                TextField("Group ID", text: $groupManager.joinGroupId)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal, 32)
                
                Button(action: {
                    Task {
                        await groupManager.joinGroup()
                    }
                }) {
                    HStack(spacing: 12) {
                        if groupManager.isJoiningGroup {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .tint(.white)
                        } else {
                            Text("Join Group")
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
                .disabled(groupManager.joinGroupId.isEmpty || groupManager.isJoiningGroup)
                .opacity(groupManager.joinGroupId.isEmpty || groupManager.isJoiningGroup ? 0.6 : 1)
            }
            
            Spacer()
        }
        .alert("Success", isPresented: $groupManager.joinSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You've successfully joined the group!")
        }
    }
    
    private var groupInfoCard: some View {
        VStack(spacing: 16) {
            // Group name and info
            VStack(spacing: 8) {
                Text(groupManager.selectedGroup?.groupName ?? "My Group")
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center)
                
                if let groupId = groupManager.selectedGroup?.groupId {
                    Text("Group ID: \(groupId)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("\(groupManager.members.count) members")
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
                ForEach(groupManager.members, id: \.user_id) { member in
                    MemberRow(member: member)
                    
                    if member.user_id != groupManager.members.last?.user_id {
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

// Preview provider
struct HouseDashboard_Previews: PreviewProvider {
    static var previews: some View {
        let groupManager = GroupSelectionManager()
        
        // Set up preview data with valid UUIDs
        groupManager.userGroups = [
            GroupModel(
                groupId: "9a5a0c2b-e789-4a8b-b9ec-ccc6ab5cacfb", // Using a valid UUID format
                groupName: "Marketing Team",
                groupImage: "",
                groupAddress: "123 Preview St",
                createdAt: "2025-05-01",
                updatedAt: "2025-05-29"
            ),
            GroupModel(
                groupId: "41e54c45-59c2-449b-9bde-3805cc0790ab", // Using a valid UUID format
                groupName: "Development Team",
                groupImage: "",
                groupAddress: "456 Preview Ave",
                createdAt: "2025-05-01",
                updatedAt: "2025-05-29"
            )
        ]
        groupManager.members = [
            ProfileModel(
                user_id: "ff56d9d8-a11a-4dca-b6c4-53eb1ba592fb", // Using a valid UUID format
                profile_first_name: "John",
                profile_last_name: "Doe",
                created_at: nil,
                updated_at: nil
            ),
            ProfileModel(
                user_id: "c2d7b699-c5b4-4d5c-a9f0-8c8161cc955b", // Using a valid UUID format
                profile_first_name: "Jane",
                profile_last_name: "Smith",
                created_at: nil,
                updated_at: nil
            )
        ]
        groupManager.selectGroup("9a5a0c2b-e789-4a8b-b9ec-ccc6ab5cacfb") // Using the first group's UUID
        
        return HouseDashboard()
    }
}
