import SwiftUI
import Supabase

struct HouseMember: Identifiable, Codable {
    var id: String
    var firstName: String
    var lastName: String
    var avatarUrl: String?
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
}

class HouseDashboardViewModel: ObservableObject {
    @Published var groupName: String = ""
    @Published var houseId: String? = nil
    @Published var members: [HouseMember] = []
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil
    @Published var showJoinGroupView = false
    @Published var joinGroupId = ""
    @Published var isJoiningGroup = false
    @Published var joinSuccess = false
    
    private let authEmail = "elmedin@test.nl"
    private let authPassword = "elmedin123"
    
    func loadGroupData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Authenticate with Supabase
                do {
                    _ = try await SupaClient.auth.signIn(email: authEmail, password: authPassword)
                } catch {
                    await MainActor.run {
                        errorMessage = "Authentication error: \(error.localizedDescription)"
                        isLoading = false
                    }
                    return
                }
                
                // Get current user ID
                let session = try await SupaClient.auth.session
                let userId = session.user.id
                if userId.uuidString.isEmpty {
                    await MainActor.run {
                        errorMessage = "Unable to get current user ID"
                        isLoading = false
                    }
                    return
                }
                
                // 1. First, check if user is part of a house
                let membershipResponse = try await SupaClient.database
                    .from("house_membership")
                    .select("house_id")
                    .eq("user_id", value: userId)
                    .execute()
                
                // Check if user has any house memberships
                if membershipResponse.data.isEmpty {
                    // User is not part of any house yet
                    await MainActor.run {
                        self.isLoading = false
                        self.showJoinGroupView = true
                    }
                    return
                }
                
                // Parse the JSON to get the house_id
                let decoder = JSONDecoder()
                let memberships = try decoder.decode([MembershipRecord].self, from: membershipResponse.data)
                
                guard let firstMembership = memberships.first else {
                    await MainActor.run {
                        self.isLoading = false
                        self.showJoinGroupView = true
                    }
                    return
                }
                
                let houseId = firstMembership.house_id!
                
                // Skip fetching house details - we don't need them
                // Just set a placeholder group name
                let groupName = "My House Group"
                
                // 3. Get all members of this house
                let allMembersResponse = try await SupaClient.database
                    .from("house_membership")
                    .select("user_id")
                    .eq("house_id", value: houseId)
                    .execute()
                
                if allMembersResponse.data.isEmpty {
                    throw NSError(domain: "HouseDashboard", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch house members"])
                }
                
                let allMemberships = try decoder.decode([MembershipRecord].self, from: allMembersResponse.data)
                let memberIds = allMemberships.compactMap { $0.user_id }
                
                // 4. Get user details for all members
                var members: [HouseMember] = []
                
                for memberId in memberIds {
                    let userResponse = try await SupaClient.database
                        .from("profiles")
                        .select("user_id, profile_first_name, profile_last_name")
                        .eq("user_id", value: memberId)
                        .execute()
                    
                    if !userResponse.data.isEmpty {
                        let users = try decoder.decode([UserRecord].self, from: userResponse.data)
                        if let user = users.first {
                            let member = HouseMember(
                                id: user.user_id,
                                firstName: user.profile_first_name,
                                lastName: user.profile_last_name,
                                avatarUrl: nil
                            )
                            members.append(member)
                        }
                    }
                }
                
                // Update UI
                await MainActor.run {
                    self.houseId = houseId
                    self.groupName = groupName
                    self.members = members
                    self.isLoading = false
                }
            } catch {
                print("Error: \(error)")
                await MainActor.run {
                    self.errorMessage = "Failed to load group data: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    func joinGroup() {
        guard !joinGroupId.isEmpty else { return }
        
        isJoiningGroup = true
        
        Task {
            do {
                // Authenticate with Supabase if needed
                let session = try await SupaClient.auth.session
                if session == nil {
                    _ = try await SupaClient.auth.signIn(email: authEmail, password: authPassword)
                }
                
                let user = try await SupaClient.auth.user()
                let userId = user.id
                if userId.uuidString.isEmpty {
                    throw NSError(domain: "HouseDashboard", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
                }
                
                // Add debug logging
                print("🔍 Attempting to join house with ID: \(joinGroupId)")
                
                // Add membership for the user with the provided house_id
                print("🏠 Creating membership with house_id: \(joinGroupId)")
                
                // Check if the house exists
                let houseCheckResponse = try await SupaClient.database
                    .from("houses")
                    .select("house_id")
                    .eq("house_id", value: joinGroupId)
                    .execute()
                
                if houseCheckResponse.data.isEmpty {
                    throw NSError(domain: "HouseDashboard", code: 1, userInfo: [NSLocalizedDescriptionKey: "House not found with ID: \(joinGroupId)"])
                }
                // Create the membership record
                let membershipData: [String: String] = [
                    "user_id": userId.uuidString,
                    "house_id": joinGroupId
                ]
                
                _ = try await SupaClient.database
                    .from("house_membership")
                    .insert(membershipData)
                    .execute()
                
                // Success - membership created
                
                await MainActor.run {
                    self.isJoiningGroup = false
                    self.joinSuccess = true
                    
                    // Reload data after successful join
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.joinSuccess = false
                        self.showJoinGroupView = false
                        self.loadGroupData()
                    }
                }
            } catch {
                print("Join error: \(error)")
                await MainActor.run {
                    self.errorMessage = "Failed to join group: \(error.localizedDescription)"
                    self.isJoiningGroup = false
                }
            }
        }
    }
}

// Data structures for Supabase responses
struct MembershipRecord: Codable {
    var user_id: String?
    var house_id: String?
}

struct HouseRecord: Codable {
    var house_id: String
    var name: String
}

struct UserRecord: Codable {
    var user_id: String
    var profile_first_name: String
    var profile_last_name: String
}

struct HouseDashboard: View {
    @StateObject private var viewModel = HouseDashboardViewModel()
    private let tealColor = Color(UIColor.systemTeal)
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.showJoinGroupView {
                    joinGroupView
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
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
                viewModel.loadGroupData()
            }
            .alert(isPresented: .constant(viewModel.errorMessage != nil)) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? "Unknown error"),
                    dismissButton: .default(Text("OK")) {
                        viewModel.errorMessage = nil
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
                TextField("House ID", text: $viewModel.joinGroupId)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal, 32)
                
                Button(action: {
                    viewModel.joinGroup()
                }) {
                    HStack(spacing: 12) {
                        if viewModel.isJoiningGroup {
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
                .disabled(viewModel.joinGroupId.isEmpty || viewModel.isJoiningGroup)
                .opacity(viewModel.joinGroupId.isEmpty || viewModel.isJoiningGroup ? 0.6 : 1)
            }
            
            Spacer()
        }
        .alert("Success", isPresented: $viewModel.joinSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You've successfully joined the house!")
        }
    }
    
    private var groupInfoCard: some View {
        VStack(spacing: 16) {
            // Group name and info
            VStack(spacing: 8) {
                Text(viewModel.groupName)
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center)
                
                if let houseId = viewModel.houseId {
                    Text("House ID: \(houseId)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("\(viewModel.members.count) members")
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
                ForEach(viewModel.members) { member in
                    MemberRow(member: member)
                    
                    if member.id != viewModel.members.last?.id {
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
        let member: HouseMember
        
        var body: some View {
            HStack(spacing: 16) {
                // Avatar
                ZStack {
                    if let avatarUrl = member.avatarUrl, let url = URL(string: avatarUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color(.systemGray5)
                        }
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 44, height: 44)
                            .overlay(
                                Text(member.firstName.prefix(1).uppercased())
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.gray)
                            )
                    }
                }
                
                // Member details
                VStack(alignment: .leading, spacing: 4) {
                    Text(member.fullName)
                        .font(.system(size: 16, weight: .medium))
                    
                    Text("Member ID: \(member.id.prefix(8))")
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

#Preview {
    HouseDashboard()
}
