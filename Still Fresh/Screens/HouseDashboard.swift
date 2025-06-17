import SwiftUI
import Supabase

struct HouseDashboard: View {
    @StateObject private var appStore = HouseStoreModel.shared
    private let tealColor = Color(UIColor.systemTeal)
    
    // State variables for popups and editing
    @State private var showLeaveConfirmation = false
    @State private var showRemoveMemberConfirmation = false
    @State private var showCreateHouseSheet = false
    @State private var memberToRemove: ProfileModel? = nil
    @State private var isEditingName = false
    @State private var editedName = ""
    @State private var showCopiedToast = false
    @State private var joinHouseId = ""

    // House selection items
    private var houseSelectionItems: [DropdownItem] {
        appStore.userHouses.map { house in
            DropdownItem(
                title: house.houseName,
                items: nil
            )
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if appStore.isLoading {
                    loadingView
                } else if appStore.selectedHouse == nil {
                    joinGroupView
                } else {
                    VStack(spacing: 24) {
                        ScrollView {
                            VStack(spacing: 24) {
                                // House info card
                                groupInfoCard
                                    .padding(.horizontal, 16)
                                
                                // Members section
                                membersSection
                                    .padding(.horizontal, 16)
                                
                                Spacer(minLength: 40)
                            }
                        }
                    }
                }
            }
            .navigationTitle("House Dashboard")
            .navigationBarTitleDisplayMode(.large)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: {
//                        showCreateHouseSheet = true
//                    }) {
//                        Image(systemName: "plus")
//                            .foregroundColor(tealColor)
//                    }
//                }
//            }
            .task {
                await appStore.loadUserHouses()
                print("DEBUG [HouseDashboard] Houses loaded - Count: \(appStore.userHouses.count)")
                print("DEBUG [HouseDashboard] Selected house: \(appStore.selectedHouse?.houseName ?? "None")")
            }
            .alert(isPresented: $appStore.joinSuccess) {
                Alert(
                    title: Text("Success"),
                    message: Text("You've successfully joined the house!"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .alert("Error", isPresented: .constant(appStore.errorMessage != nil)) {
                Button("OK", role: .cancel) {
                    appStore.errorMessage = nil
                }
            } message: {
                Text(appStore.errorMessage ?? "Unknown error")
            }
            // Leave house confirmation
            .sheet(isPresented: $showLeaveConfirmation) {
                ConfirmationPopup(
                    title: "Leave House",
                    message: "Are you sure you want to leave this house? This action cannot be undone.",
                    confirmText: "Leave",
                    isDestructive: true,
                    isPresented: $showLeaveConfirmation
                ) {
                    Task {
                        if let houseId = appStore.selectedHouse?.houseId {
                            try? await appStore.leaveHouse(houseId: houseId)
                        }
                    }
                }
            }
            // Create house sheet
            .sheet(isPresented: $showCreateHouseSheet) {
                CreateHouseView(isPresented: $showCreateHouseSheet) {
                    Task {
                        await appStore.loadUserHouses()
                    }
                }
            }
        }
        // Remove member confirmation - moved outside NavigationView
        .sheet(isPresented: $showRemoveMemberConfirmation) {
            if let member = memberToRemove {
                ConfirmationPopup(
                    title: "Remove Member",
                    message: "Are you sure you want to remove \(member.profile_first_name) from the house?",
                    confirmText: "Remove",
                    isDestructive: true,
                    isPresented: $showRemoveMemberConfirmation
                ) {
                    Task {
                        if let houseId = appStore.selectedHouse?.houseId {
                            try? await appStore.removeMember(userId: member.user_id, houseId: houseId)
                        }
                    }
                }
            }
        }
        // Copied to clipboard toast
        .overlay(
            Group {
                if showCopiedToast {
                    VStack {
                        Spacer()
                        Text("Copied to clipboard!")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.75))
                            .cornerRadius(8)
                            .padding(.bottom, 32)
                    }
                    .transition(.move(edge: .bottom))
                }
            }
        )
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
                
                Text("Join or Create a House")
                    .font(.system(size: 24, weight: .bold))
                
                Text("Enter a house ID to join an existing house or create a new one")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            VStack(spacing: 16) {
                TextField("House ID", text: $joinHouseId)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal, 32)
                    .onChange(of: joinHouseId) { _, newValue in
                        appStore.joinHouseId = newValue
                    }
                
                Button(action: {
                    Task {
                        await appStore.joinHouse()
                    }
                }) {
                    HStack(spacing: 12) {
                        if appStore.isJoiningHouse {
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
                .disabled(joinHouseId.isEmpty || appStore.isJoiningHouse)
                .opacity(joinHouseId.isEmpty || appStore.isJoiningHouse ? 0.6 : 1)
                
                Button(action: {
                    showCreateHouseSheet = true
                }) {
                    Text("Create New House")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .foregroundColor(tealColor)
                        .cornerRadius(10)
                        .padding(.horizontal, 32)
                }
            }
            
            Spacer()
        }
        .alert("Success", isPresented: .constant(appStore.joinSuccess)) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You've successfully joined the house!")
        }
    }
    
    private var groupInfoCard: some View {
        VStack(spacing: 16) {
            // House name and info
            VStack(spacing: 8) {
                HStack {
                    if isEditingName {
                        TextField("House Name", text: $editedName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onSubmit {
                                Task {
                                    if let houseId = appStore.selectedHouse?.houseId {
                                        do {
                                            try await appStore.updateHouseName(houseId: houseId, newName: editedName)
                                            isEditingName = false
                                        } catch {
                                            print("Error updating house name: \(error)")
                                        }
                                    }
                                }
                            }
                    } else {
                        Text(appStore.selectedHouse?.houseName ?? "My House")
                            .font(.system(size: 24, weight: .bold))
                        
                        Button(action: {
                            editedName = appStore.selectedHouse?.houseName ?? ""
                            isEditingName = true
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .multilineTextAlignment(.center)
                
                if let houseId = appStore.selectedHouse?.houseId {
                    Text("House ID: \(houseId)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("\(appStore.houseMembers.count) members")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // House actions
            HStack(spacing: 20) {
                Button(action: {
                    if let houseId = appStore.selectedHouse?.houseId {
                        UIPasteboard.general.string = houseId
                        withAnimation {
                            showCopiedToast = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showCopiedToast = false
                            }
                        }
                    }
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 20))
                        Text("Invite!")
                            .font(.system(size: 14))
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Button(action: {
                    showLeaveConfirmation = true
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 20))
                        Text("Leave")
                            .font(.system(size: 14))
                    }
                    .frame(maxWidth: .infinity)
                }
                .foregroundColor(.red)
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
            Text("Members")
                .font(.system(size: 20, weight: .bold))
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                ForEach(appStore.houseMembers, id: \.user_id) { member in
                    MemberRow(
                        member: member,
                        onRemove: {
                            memberToRemove = member
                            showRemoveMemberConfirmation = true
                        }
                    )
                    
                    if member.user_id != appStore.houseMembers.last?.user_id {
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
        let onRemove: () -> Void
        @State private var showOptions = false
        
        var fullName: String {
            return "\(member.profile_first_name) \(member.profile_last_name)"
        }
        
        var body: some View {
            HStack(spacing: 16) {
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
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(fullName)
                        .font(.system(size: 16, weight: .medium))
                    
                    Text("Member ID: \(member.user_id.prefix(8))")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Menu {
                    Button(role: .destructive, action: onRemove) {
                        Label("Remove Member", systemImage: "person.fill.xmark")
                    }
                } label: {
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
        let appStore = HouseStoreModel.shared
        
        // Load real data from database
        Task {
            await appStore.loadUserHouses()
        }
        
        return HouseDashboard()
    }
}
