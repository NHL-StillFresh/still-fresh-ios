import SwiftUI

struct HomeView: View {
    @State private var productLines: [String] = []
    @State private var showCamera = false
    let recognizer = TextRecognizer()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, Home!")
        }
        .padding()
        
        Spacer()
        
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
