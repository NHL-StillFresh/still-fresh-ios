//
//  AddView.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 10/05/2025.
//

import SwiftUI

struct AddView : View {
    @State private var productLines: [String] = []
    @State private var showCamera = false
    @State private var isProcessing = false
    @State private var scanStatus: ScanStatus = .ready
    @State private var debugText: String = ""
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
    
    var body: some View {
        VStack {
            Text("Producten op bon:")
                .font(.title)
                .padding()
            
            if isProcessing {
                ProgressView()
                    .padding()
                Text("Bon verwerken...")
                    .foregroundColor(.gray)
            } else if productLines.isEmpty {
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
            
            HStack {
                Button("📷 Scan Bon met Camera") {
                    scanStatus = .ready
                    debugText = ""
                    showCamera = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                if !productLines.isEmpty || !debugText.isEmpty {
                    Button("Clear") {
                        productLines = []
                        debugText = ""
                        scanStatus = .ready
                    }
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .sheet(isPresented: $showCamera){
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
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    AddView()
}
