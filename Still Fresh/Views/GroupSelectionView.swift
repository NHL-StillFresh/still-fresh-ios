import SwiftUI

struct GroupSelectionView: View {
    @StateObject private var appStore = AppStore.shared
    
    var body: some View {
        VStack {
            if appStore.isLoading {
                ProgressView()
            } else if appStore.userHouses.isEmpty {
                Text("No houses found")
                    .foregroundColor(.secondary)
            } else {
                ForEach(appStore.userHouses, id: \.houseId) { house in
                    Button(action: {
                        Task {
                            await appStore.selectHouse(houseId: house.houseId)
                        }
                    }) {
                        HStack {
                            Text(house.houseName)
                            Spacer()
                            if house.houseId == appStore.selectedHouse?.houseId {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(house.houseId == appStore.selectedHouse?.houseId ? Color.blue.opacity(0.1) : Color.clear)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .task {
            await appStore.loadUserHouses()
        }
    }
} 