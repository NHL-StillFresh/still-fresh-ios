import SwiftUI
import Supabase
import CoreImage.CIFilterBuiltins
import AVFoundation

struct QRScannerView: UIViewControllerRepresentable {
    @Binding var scannedCode: String
    @Binding var isShowingScanner: Bool
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: QRScannerView
        
        init(_ parent: QRScannerView) {
            self.parent = parent
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
               let stringValue = metadataObject.stringValue {
                parent.scannedCode = stringValue
                parent.isShowingScanner = false
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let session = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return viewController }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return viewController
        }
        
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        } else {
            return viewController
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return viewController
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = viewController.view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)
        
        session.startRunning()
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct HouseDashboard: View {
    @StateObject private var appStore = HouseStoreModel()
    private let tealColor = Color(UIColor.systemTeal)
    
    @State private var showLeaveConfirmation = false
    @State private var showRemoveMemberConfirmation = false
    @State private var showCreateHouseSheet = false
    @State private var showQRCodeSheet = false
    @State private var showQRScanner = false
    @State private var memberToRemove: ProfileModel? = nil
    @State private var isEditingName = false
    @State private var editedName = ""
    @State private var showCopiedToast = false
    @State private var joinHouseId = ""
    @Environment(\.dismiss) private var dismiss
    
    // QR Code generation function
    private func generateQRCode(from string: String) -> UIImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.message = Data(string.utf8)
        filter.correctionLevel = "H"
        
        if let outputImage = filter.outputImage {
            let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
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
                                groupInfoCard
                                    .padding(.horizontal, 16)
                                
                                membersSection
                                    .padding(.horizontal, 16)
                                
                                Button(action: {
                                    dismiss()
                                }) {
                                    Text("Close")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                        .background(Color(red: 0.04, green: 0.29, blue: 0.29))
                                        .cornerRadius(12)
                                }
                                .padding(.top, 8)
                                
                                Spacer(minLength: 40)
                            }
                        }
                    }
                }
            }
            .navigationTitle("House Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await appStore.loadUserHouses()
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
            // Create house sheet
            .sheet(isPresented: $showCreateHouseSheet) {
                CreateHouseView(isPresented: $showCreateHouseSheet) {
                    Task {
                        await appStore.loadUserHouses()
                    }
                }
            }
        }
        .alert("Leave House?", isPresented: $showLeaveConfirmation, actions: {
            Button("Cancel") {
                showRemoveMemberConfirmation = false
            }
            
            Button(action: {
                showRemoveMemberConfirmation = false
                Task {
                    if let houseId = appStore.selectedHouse?.houseId {
                        try? await appStore.leaveHouse(houseId: houseId)
                    }
                }
            }) {
                Text("Leave house")
                    .foregroundStyle(Color.red)
            }
        })
        .alert("Remove Member?", isPresented: $showRemoveMemberConfirmation, actions: {
            Button("Cancel") {
                showRemoveMemberConfirmation = false
            }
            
            Button(action: {
                showRemoveMemberConfirmation = false
                Task {
                    if let member = memberToRemove, let houseId = appStore.selectedHouse?.houseId {
                        try? await appStore.removeMember(userId: member.user_id, houseId: houseId)
                    }
                }
            }) {
                Text("Remove")
                    .foregroundStyle(Color.red)
            }
        })
        .alert("Copied to clipboard!", isPresented: $showCopiedToast, actions: {
            Button("OK") {
                showCopiedToast = false
            }
        })
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
                HStack {
                    TextField("House ID", text: $joinHouseId)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .onChange(of: joinHouseId) { _, newValue in
                            appStore.joinHouseId = newValue
                        }
                    
                    Button(action: {
                        showQRScanner = true
                    }) {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.system(size: 24))
                            .foregroundColor(tealColor)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 32)
                
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
        .fullScreenCover(isPresented: $showQRScanner) {
            ZStack {
                QRScannerView(scannedCode: $joinHouseId, isShowingScanner: $showQRScanner)
                
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            showQRScanner = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                    
                    Spacer()
                    
                    Text("Scan House QR Code")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                        .padding(.bottom, 50)
                }
            }
            .edgesIgnoringSafeArea(.all)
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
                    showQRCodeSheet = true
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "qrcode")
                            .font(.system(size: 20))
                        Text("QR Code")
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
        .sheet(isPresented: $showQRCodeSheet) {
            if let houseId = appStore.selectedHouse?.houseId {
                VStack(spacing: 24) {
                    Text("Scan to Join House")
                        .font(.title2)
                        .bold()
                    
                    Image(uiImage: generateQRCode(from: houseId))
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                    
                    Text(houseId)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button("Done") {
                        showQRCodeSheet = false
                    }
                    .padding()
                    .background(tealColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
            }
        }
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
                    AsyncImage(url: AvatarGenerator.generateAvatarImageURL(withName: fullName)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Color.teal, lineWidth: 2)
                            )
                    } placeholder: {
                        ProgressView()
                            .frame(width: 44, height: 44)
                    }
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
        let appStore = HouseStoreModel()
        
        // Load real data from database
        Task {
            await appStore.loadUserHouses()
        }
        
        return HouseDashboard()
    }
}
