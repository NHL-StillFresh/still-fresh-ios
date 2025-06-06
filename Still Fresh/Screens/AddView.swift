//
//  AddView.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 10/05/2025.
//

import SwiftUI

struct AddView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedOption: AddOption?
    @State private var appearAnimation = false
    
    @State private var productLines: [String] = []
    @State private var showCamera = false
    @State private var showImageUploader = false
    @State private var isProcessing = false
    @State private var scanStatus: ScanStatus = .ready
    @State private var debugText: String = ""
    @State private var showScanResults = false
    @State private var showAddProductManuallyView = false
    let recognizer = TextRecognizer()
    
    enum ScanStatus {
        case ready, processing, success, noProductsFound, error
        
        var message: String {
            switch self {
                case .ready: return "Press scan to start"
                case .processing: return "Processing receipt..."
                case .success: return ""
                case .noProductsFound: return "No products found on this receipt"
                case .error: return "An error occurred while scanning the receipt"
            }
        }
    }
    
    enum AddOption: String, CaseIterable, Identifiable {
        case scanReceipt = "Scan receipt"
        case addProduct = "Add manually"
        case uploadImage = "Upload image"
        
        var id: String { self.rawValue }
        
        var iconName: String {
            switch self {
            case .scanReceipt: return "doc.text.viewfinder"
            case .addProduct: return "plus.circle"
            case .uploadImage: return "photo"
            }
        }
        
        var description: String {
            switch self {
            case .scanReceipt: return "Scan a receipt to add products"
            case .addProduct: return "Add a product manually"
            case .uploadImage: return "Upload an image with products"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Title
            Text("Add products")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 12)
            
            // Options - Using VStack with reduced spacing
            VStack(spacing: 12) {
                ForEach(AddOption.allCases) { option in
                    OptionButton(option: option, selectedOption: $selectedOption)
                        .scaleEffect(appearAnimation ? 1 : 0.95)
                        .opacity(appearAnimation ? 1 : 0)
                        .animation(
                            .spring(response: 0.3, dampingFraction: 0.7)
                            .delay(0.05 * Double(getIndex(for: option))),
                            value: appearAnimation
                        )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            
            Spacer(minLength: 0)
        }
        .frame(height: 310)
        .padding(.top, 24)
//        .background(
//            RoundedRectangle(cornerRadius: 24)
//                .fill(Color(UIColor.systemBackground))
//                .ignoresSafeArea(edges: .bottom)
//                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: -5)
//        )
        .onAppear {
            withAnimation {
                appearAnimation = true
            }
        }
        .onChange(of: selectedOption) { oldValue, newValue in
            if newValue != nil {
                handleOptionSelection(newValue!)
            }
        }
        .sheet(isPresented: $showAddProductManuallyView, onDismiss: { selectedOption = nil }) {
            AddProductManuallyView()
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showCamera, onDismiss: {
            selectedOption = nil
        }) {
            ImagePicker(sourceType: .camera) { image in
                isProcessing = true
                scanStatus = .processing
                
                Task {
                    try await recognizer.performOCR(imageData: image.jpegData(compressionQuality: 1)!)
                }
                                
                self.productLines = recognizer.observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }
                                
                if (productLines.count > 1) && ((productLines[0].contains("=") || (productLines[0].lowercased().contains("totaal"))) || (productLines[0].lowercased().contains("betaald"))) {
                 productLines.remove(at: 0)
                }
                
                if self.productLines.isEmpty {
                    scanStatus = .noProductsFound
                } else {
                    scanStatus = .success
                }

                if !recognizer.scanSucceeded {
                    scanStatus = .noProductsFound
                }
                
                showImageUploader = false
                showScanResults = true
            }
        }
        .sheet(isPresented: $showScanResults) {
            ScanResultsView(productLines: productLines, debugText: debugText, scanStatus: scanStatus) {
                showScanResults = false
                dismiss()
            }.background(Color(.white))
        }
        .sheet(isPresented: $showImageUploader) {
            SingleImagePicker { data in
                isProcessing = true
                scanStatus = .processing
                
                Task {
                    try await recognizer.performOCR(imageData: data)
                }
            
                print(recognizer.observations)
                
                self.productLines = recognizer.observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }
                                
                if (productLines.count > 1) && (productLines[0].contains("=")) {
                 productLines.remove(at: 0)
                }
                
                if self.productLines.isEmpty {
                    scanStatus = .noProductsFound
                } else {
                    scanStatus = .success
                }
                
                showScanResults = true
            }
        }
    }
    
    private func getIndex(for option: AddOption) -> Int {
        return AddOption.allCases.firstIndex(of: option) ?? 0
    }
    
    private func handleOptionSelection(_ option: AddOption) {
        switch option {
            case .scanReceipt:
                scanStatus = .ready
                debugText = ""
                showCamera = true
            case .addProduct:
                showAddProductManuallyView = true
            case .uploadImage:
                showImageUploader = true
        }
    }
    
}

struct OptionButton: View {
    let option: AddView.AddOption
    @Binding var selectedOption: AddView.AddOption?
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            selectedOption = option
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.04, green: 0.29, blue: 0.29).opacity(0.08))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: option.iconName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(UIColor.systemTeal))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(option.rawValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(option.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                .padding(.vertical, 2)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
                    .padding(.trailing, 2)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PressButtonStyle())
    }
}

struct PressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .brightness(configuration.isPressed ? -0.03 : 0)
    }
}

struct ScanResultsView: View {
    @State var productLines: [String]
    let debugText: String
    let scanStatus: AddView.ScanStatus
    let onDone: () -> Void
    @State private var showProductsView: Bool = false
    @State private var showAlert = false
    @State private var itemToRemove: String? = nil

    
    var body: some View {
        VStack {
            Text("Products on receipt:")
                .font(.title)
                .padding()
            
            Text("Verify that the scan contains no errors")
            
            List(productLines, id: \.self) { line in
                HStack {
                    Text(line)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Button(action: {
                        itemToRemove = line
                        showAlert = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
                .padding(.vertical, 8)
                .lineSpacing(8)
                .listRowBackground(Color(UIColor.systemBackground))
            }
            .scrollContentBackground(.hidden)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Confirm Removal"),
                    message: Text("Are you sure you want to remove \(itemToRemove ?? "")?"),
                    primaryButton: .destructive(Text("Remove")) {
                        if let item = itemToRemove, let index = productLines.firstIndex(of: item) {
                            productLines.remove(at: index)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            
            
            Spacer()
            
            Button("Next") {
                showProductsView = true
            }
            .padding()
            .frame(minWidth: 120)
            .background(Color(red: 0.04, green: 0.29, blue: 0.29))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.bottom)
            .sheet(isPresented: $showProductsView) {
                CheckProductsView(productLines: productLines)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()
        AddView()
    }
}
