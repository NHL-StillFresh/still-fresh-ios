//
//  GenericLoader.swift
//  Still Fresh
//
//  Created by Jesse van der Voet on 21/05/2025.
//

import SwiftUI

struct GenericLoader: View {
    @State private var isAnimating = false
    @State private var trimEnd: CGFloat = 0.2
    
    var body: some View {
        ZStack {
            Color("LoginBackgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                MarqueeImage(imageName: "LoginImage", height: UIScreen.main.bounds.height * 0.45)
                    .padding(.top, 32)
                
                Spacer(minLength: 0)
                
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.18), lineWidth: 8)
                        .frame(width: 56, height: 56)
                    Circle()
                        .trim(from: 0, to: trimEnd)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 56, height: 56)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        .animation(.linear(duration: 1.1).repeatForever(autoreverses: false), value: isAnimating)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: trimEnd)
                }
                .padding(.top, 8)
                
                Text("Loading...")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .opacity(0.9)
                
                Spacer()
            }
        }
        .onAppear {
            isAnimating = true
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                trimEnd = 0.8
            }
        }
    }
}

struct MarqueeImage: View {
    let imageName: String
    let height: CGFloat
    @State private var offset: CGFloat = 0
    @State private var imageWidth: CGFloat = 1 // Will be set after image loads
    let speed: CGFloat = 60 // points per second
    @State private var timer: Timer? = nil

    var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            HStack(spacing: 0) {
                ForEach(0..<tileCount(for: totalWidth), id: \.self) { _ in
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: height)
                        .background(WidthReader(width: $imageWidth))
                }
            }
            .offset(x: offset)
            .frame(width: totalWidth, height: height, alignment: .leading)
            .clipped()
            .onAppear {
                startMarquee(totalWidth: totalWidth)
            }
            .onDisappear {
                timer?.invalidate()
            }
            .onChange(of: imageWidth) { 
                startMarquee(totalWidth: totalWidth)
            }
        }
        .frame(height: height)
    }

    func tileCount(for totalWidth: CGFloat) -> Int {
        guard imageWidth > 0 else { return 3 }
        // +2 for seamless looping
        return Int(ceil(totalWidth / imageWidth)) + 2
    }

    func startMarquee(totalWidth: CGFloat) {
        timer?.invalidate()
        guard imageWidth > 1 else { return }
        offset = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { _ in
            let step = speed / 60 // points per frame
            offset -= step
            if abs(offset) >= imageWidth {
                offset += imageWidth
            }
        }
    }
}

// Helper view to read the width of the image
struct WidthReader: View {
    @Binding var width: CGFloat
    var body: some View {
        GeometryReader { geo in
            Color.clear
                .onAppear { width = geo.size.width }
        }
    }
}

#Preview {
    GenericLoader()
}
