import SwiftUI

struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []
    @State private var animationTimer: Timer?
    @State private var shouldContinue = true
    
    let isActive: Bool
    
    var body: some View {
        ZStack {
            ForEach(confettiPieces) { piece in
                Text(piece.emoji)
                    .font(.system(size: piece.size))
                    .position(x: piece.x, y: piece.y)
                    .rotationEffect(.degrees(piece.rotation))
                    .opacity(piece.opacity)
                    .animation(.easeOut(duration: piece.duration), value: piece.y)
                    .animation(.linear(duration: piece.duration), value: piece.rotation)
            }
        }
        .onAppear {
            if isActive {
                startConfetti()
            }
        }
        .onChange(of: isActive) {_, newValue in
            if newValue {
                shouldContinue = true
                startConfetti()
            } else {
                shouldContinue = false
                gracefulStop()
            }
        }
    }
    
    private func startConfetti() {
        // Initial burst
        createConfettiBurst()
        
        // Continuous confetti (reduced frequency and duration)
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
            if isActive && shouldContinue {
                createConfettiPieces(count: 2)
            }
        }
        
        // Auto-stop after 3 seconds (shorter duration)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            gracefulStop()
        }
    }
    
    private func gracefulStop() {
        shouldContinue = false
        animationTimer?.invalidate()
        animationTimer = nil
        
        // Don't immediately fade out - let existing pieces complete their natural animation
        // Only clear very old pieces that might be stuck
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            confettiPieces.removeAll()
        }
    }
    
    private func stopConfetti() {
        shouldContinue = false
        animationTimer?.invalidate()
        animationTimer = nil
        
        // Immediate fade for emergency stop
        withAnimation(.easeOut(duration: 0.5)) {
            for index in confettiPieces.indices {
                confettiPieces[index].opacity = 0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            confettiPieces.removeAll()
        }
    }
    
    private func createConfettiBurst() {
        createConfettiPieces(count: 30) // Reduced initial burst for better performance
    }
    
    private func createConfettiPieces(count: Int) {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let emojis = ["🎉", "🎊", "✨", "🌟", "💫", "🎈", "🎁", "🏆", "👏", "🙌", "🥳", "😄", "🎯", "💚", "🌱", "🍃"]
        
        for _ in 0..<count {
            let piece = ConfettiPiece(
                id: UUID(),
                emoji: emojis.randomElement() ?? "🎉",
                x: CGFloat.random(in: 0...screenWidth),
                y: -50,
                targetY: screenHeight + 100,
                size: CGFloat.random(in: 16...28),
                rotation: Double.random(in: 0...360),
                targetRotation: Double.random(in: 360...720),
                opacity: 1.0,
                duration: Double.random(in: 1.8...3.2) // Slightly shorter for better slide transitions
            )
            
            confettiPieces.append(piece)
            
            // Animate the piece
            withAnimation(.easeOut(duration: piece.duration)) {
                if let index = confettiPieces.firstIndex(where: { $0.id == piece.id }) {
                    confettiPieces[index].y = piece.targetY
                    confettiPieces[index].rotation = piece.targetRotation
                }
            }
            
            // Remove piece after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + piece.duration) {
                confettiPieces.removeAll { $0.id == piece.id }
            }
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id: UUID
    let emoji: String
    var x: CGFloat
    var y: CGFloat
    let targetY: CGFloat
    let size: CGFloat
    var rotation: Double
    let targetRotation: Double
    var opacity: Double
    let duration: Double
}

#Preview {
    ConfettiView(isActive: true)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.1))
} 
