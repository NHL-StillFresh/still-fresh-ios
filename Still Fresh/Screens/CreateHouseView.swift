import SwiftUI

struct CreateHouseView: View {
    @Binding var isPresented: Bool
    var onCreated: () -> Void
    @StateObject private var appStore = HouseStoreModel()
    
    @State private var houseName = ""
    @State private var houseAddress = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let tealColor = Color(UIColor.systemTeal)
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("House Name", text: $houseName)
                    TextField("Address (Optional)", text: $houseAddress)
                } header: {
                    Text("HOUSE DETAILS")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Create House")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: createHouse) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .tint(tealColor)
                        } else {
                            Text("Create")
                                .bold()
                                .foregroundColor(houseName.isEmpty ? .gray : tealColor)
                        }
                    }
                    .disabled(houseName.isEmpty || isLoading)
                }
            }
        }
    }
    
    private func createHouse() {
        guard !houseName.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await appStore.createHouse(name: houseName, address: houseAddress)
                await MainActor.run {
                    isLoading = false
                    onCreated()
                    isPresented = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    CreateHouseView(isPresented: .constant(true)) {}
} 
