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
                Image("LoginImage")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.height * 0.45)
                    .clipped()
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

#Preview {
    GenericLoader()
}
