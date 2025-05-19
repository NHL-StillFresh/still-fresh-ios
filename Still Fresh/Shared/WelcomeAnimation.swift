import SwiftUI
import Combine

struct WelcomeAnimation: View {
    let username: String
    @Binding var isPresented: Bool
    
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.8
    @State private var rotation: Double = -5
    
    var body: some View {
        ZStack {
            Color("LoginBackgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(rotation))
                    .scaleEffect(scale)
                    .opacity(opacity)
                
                Text("Welcome back")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .opacity(opacity)
                    .scaleEffect(scale)
                
                Text(username)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.9))
                    .opacity(opacity)
                    .scaleEffect(scale)
                    .padding(.top, -10)
            }
        }
        .onAppear {
            // Set flag to enable HomeView animations after login
            UserDefaults.standard.set(true, forKey: "shouldAnimateHomeView")
            
            animateIn()
            
            // Auto-dismiss after animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                animateOut()
            }
        }
    }
    
    private func animateIn() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            opacity = 1
            scale = 1
            rotation = 0
        }
    }
    
    private func animateOut() {
        withAnimation(.easeOut(duration: 0.4)) {
            opacity = 0
            scale = 1.2
        }
        
        // Dismiss after animation completes - slightly faster
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            isPresented = false
        }
    }
}

#Preview {
    WelcomeAnimation(username: "John", isPresented: .constant(true))
} 