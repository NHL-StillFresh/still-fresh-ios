import SwiftUI

struct TextRecognizerDebugView: View {
    @State private var inputImage: UIImage?
    @State private var debugImage: UIImage?
    @State private var recognizedLines: [String] = []
    @State private var isShowingImagePicker = false
    @State private var isShowingCamera = false
    @State private var isProcessing = false
    @State private var showFullScreenImage = false
    let recognizer = TextRecognizer()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                if let debugImage = debugImage {
                    Button(action: { showFullScreenImage = true }) {
                        Image(uiImage: debugImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical)
                            .cornerRadius(12)
                            .shadow(radius: 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 300)
                        .overlay(Text("No image selected").foregroundColor(.gray))
                        .cornerRadius(12)
                }
                HStack(spacing: 16) {
                    Button(action: { isShowingImagePicker = true }) {
                        HStack {
                            Image(systemName: "photo")
                            Text("Pick from Library")
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    Button(action: { isShowingCamera = true }) {
                        HStack {
                            Image(systemName: "camera")
                            Text("Take Photo")
                        }
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
                if isProcessing {
                    ProgressView("Processing...")
                        .padding()
                }
                if !recognizedLines.isEmpty {
                    Text("Recognized Text (\(recognizedLines.count)):")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top)
                    ScrollView {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(recognizedLines.indices, id: \ .self) { i in
                                Text("\(i+1). \(recognizedLines[i])")
                                    .font(.system(.footnote, design: .monospaced))
                                    .padding(.vertical, 2)
                            }
                        }
                        .padding(8)
                    }
                    .frame(maxHeight: 200)
                    .background(Color.gray.opacity(0.08))
                    .cornerRadius(8)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("TextRecognizer Debug")
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(sourceType: .photoLibrary) { image in
                    self.inputImage = image
                    self.isProcessing = true
                    self.debugImage = nil
                    self.recognizedLines = []
                    recognizer.debugRecognizeText(in: image) { resultImage, lines in
                        DispatchQueue.main.async {
                            self.debugImage = resultImage
                            self.recognizedLines = lines
                            self.isProcessing = false
                        }
                    }
                }
            }
            .sheet(isPresented: $isShowingCamera) {
                ImagePicker(sourceType: .camera) { image in
                    self.inputImage = image
                    self.isProcessing = true
                    self.debugImage = nil
                    self.recognizedLines = []
                    recognizer.debugRecognizeText(in: image) { resultImage, lines in
                        DispatchQueue.main.async {
                            self.debugImage = resultImage
                            self.recognizedLines = lines
                            self.isProcessing = false
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showFullScreenImage) {
                if let debugImage = debugImage {
                    ZStack(alignment: .topTrailing) {
                        Color.black.ignoresSafeArea()
                        Image(uiImage: debugImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black)
                            .onTapGesture { showFullScreenImage = false }
                        Button(action: { showFullScreenImage = false }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    TextRecognizerDebugView()
} 