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
    let recognizer = TextRecognizer()
    
    var body: some View {
        VStack {
            Text("Producten op bon:")
                .font(.title)
                .padding()
            
            if productLines.isEmpty {
                Text("Druk op Scan om te starten")
                    .foregroundColor(.gray)
            } else {
                List(productLines, id: \.self) { line in
                    Text(line)
                }
            }
            
            
            Spacer()
            
            Button("📷 Scan Bon met Camera") {
                showCamera = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .sheet(isPresented: $showCamera){
            ImagePicker(sourceType: .camera) { image in
                recognizer.extractProductLines(from: image) { lines in
                    DispatchQueue.main.async {
                        self.productLines = lines
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
