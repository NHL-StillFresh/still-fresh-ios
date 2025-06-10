import SwiftUI

struct GroupSelectionView: View {
    @StateObject private var groupManager = GroupSelectionManager()
    
    var body: some View {
        NavigationView {
            Group {
                if groupManager.isLoading {
                    ProgressView("Loading groups...")
                } else {
                    List(groupManager.userGroups, id: \.groupId) { group in
                        GroupRowView(group: group, isSelected: group.groupId == groupManager.selectedGroupId)
                            .onTapGesture {
                                groupManager.selectGroup(group.groupId)
                            }
                    }
                }
            }
            .navigationTitle("Select Group")
            .task {
                await groupManager.loadUserGroups()
            }
        }
    }
}

struct GroupRowView: View {
    let group: GroupModel
    let isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(group.groupName)
                    .font(.headline)
                if let address = group.groupAddress {
                    Text(address)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 8)
    }
} 