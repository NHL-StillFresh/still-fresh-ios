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
    @State private var isProcessing = false
    @State private var scanStatus: ScanStatus = .ready
    @State private var debugText: String = ""
    @State private var showScanResults = false
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
        case scanProduct = "Scan product"
        
        var id: String { self.rawValue }
        
        var iconName: String {
            switch self {
            case .scanReceipt: return "doc.text.viewfinder"
            case .addProduct: return "plus.circle"
            case .scanProduct: return "barcode.viewfinder"
            }
        }
        
        var description: String {
            switch self {
            case .scanReceipt: return "Scan a receipt to add products"
            case .addProduct: return "Add a product manually"
            case .scanProduct: return "Scan a barcode of a product"
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
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(UIColor.systemBackground))
                .ignoresSafeArea(edges: .bottom)
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: -5)
        )
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

        .sheet(isPresented: $showCamera, onDismiss: {
            // Reset selectedOption when the camera is dismissed
            selectedOption = nil
        }) {
            ImagePicker(sourceType: .camera) { image in
                isProcessing = true
                scanStatus = .processing
                
                recognizer.extractProductLines(from: image) { lines in
                    DispatchQueue.main.async {
                        isProcessing = false
                        self.productLines = lines
                        
                        var debugInfo = "Image size: \(image.size.width)x\(image.size.height)\n"
                        debugInfo += "Detected \(lines.count) products\n"
                        
                        if lines.isEmpty {
                            scanStatus = .noProductsFound
                        } else {
                            scanStatus = .success
                        }
                        
                        for (index, line) in lines.enumerated() {
                            debugInfo += "Product \(index+1): \(line)\n"
                        }
                        
                        debugText = debugInfo
                        
                        print("Detected lines: \(lines.count)")
                        for (index, line) in lines.enumerated() {
                            print("Line \(index): \(line)")
                        }
                        
                        // Show results after processing is complete
                        showScanResults = true
                    }
                }
            }
        }
        .sheet(isPresented: $showScanResults) {
            ScanResultsView(productLines: productLines, debugText: debugText, scanStatus: scanStatus) {
                showScanResults = false
                dismiss()
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
        default:
            dismiss()
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
            
            if productLines.isEmpty {
                Text(scanStatus.message)
                    .foregroundColor(.gray)
                    .padding()
                
                if !debugText.isEmpty {
                    Text("Debug Info")
                        .font(.headline)
                        .padding(.top)
                    
                    ScrollView {
                        Text(debugText)
                            .font(.system(.footnote, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                    }
                    .frame(maxHeight: 200)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding()
                }
            } else {
                List(productLines, id: \.self) { line in
                    
                    Button(line) {
                        itemToRemove = line
                        showAlert = true
                    }
                }.alert(isPresented: $showAlert) {
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
