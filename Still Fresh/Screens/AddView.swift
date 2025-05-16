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
    
    // Add states for receipt scanning
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
                case .ready: return "Druk op Scan om te starten"
                case .processing: return "Bon verwerken..."
                case .success: return ""
                case .noProductsFound: return "Geen producten gevonden op deze bon"
                case .error: return "Er is een fout opgetreden bij het scannen"
            }
        }
    }
    
    enum AddOption: String, CaseIterable, Identifiable {
        case scanReceipt = "Scan bon"
        case addProduct = "Voeg product toe"
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
            case .scanReceipt: return "Scan een kassabon om producten toe te voegen"
            case .addProduct: return "Voeg handmatig een product toe"
            case .scanProduct: return "Scan een barcode van een product"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag indicator
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 12)
            
            // Title
            Text("Toevoegen")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
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
        .background(
            // This makes the edges rounded and adds a background
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(UIColor.systemBackground))
                .ignoresSafeArea(edges: .bottom)
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: -5)
        )
        .onAppear {
            // Animate options appearing
            withAnimation {
                appearAnimation = true
            }
        }
        .onChange(of: selectedOption) { newValue in
            if newValue != nil {
                // Immediately handle selection without delay
                handleOptionSelection(newValue!)
            }
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(sourceType: .camera) { image in
                isProcessing = true
                scanStatus = .processing
                
                recognizer.extractProductLines(from: image) { lines in
                    DispatchQueue.main.async {
                        isProcessing = false
                        self.productLines = lines
                        
                        // Collect debugging info
                        var debugInfo = "Image size: \(image.size.width)x\(image.size.height)\n"
                        debugInfo += "Detected \(lines.count) products\n"
                        
                        // Show raw text lines for debugging
                        if lines.isEmpty {
                            scanStatus = .noProductsFound
                            
                            // Try to get and add the JUMBO COLA manually for testing
                            let knownProducts = ["JUMBO COLA FLES 500M 0,40", "STATIEGELD 0,15"]
                            if debugText.isEmpty {
                                self.productLines = knownProducts
                                debugInfo += "Added test products for debugging\n"
                                scanStatus = .success
                            }
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
            // Immediately dismiss without delay
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
            // Set selection immediately without animation delay
            selectedOption = option
        }) {
            HStack(spacing: 16) {
                // Slightly smaller icon for more compact layout
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
        .buttonStyle(PressButtonStyle()) // Using a simpler immediate feedback style
    }
}

// Simple feedback without delays
struct PressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .brightness(configuration.isPressed ? -0.03 : 0)
    }
}

// Add a new view to display scan results
struct ScanResultsView: View {
    let productLines: [String]
    let debugText: String
    let scanStatus: AddView.ScanStatus
    let onDone: () -> Void
    
    var body: some View {
        VStack {
            Text("Producten op bon:")
                .font(.title)
                .padding()
            
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
                    Text(line)
                }
            }
            
            Spacer()
            
            Button("Gereed") {
                onDone()
            }
            .padding()
            .frame(minWidth: 120)
            .background(Color(red: 0.04, green: 0.29, blue: 0.29))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.bottom)
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()
        AddView()
    }
}
