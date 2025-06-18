import Foundation
import AVFoundation
import SwiftUI

class SoundEffectPlayer: ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    
    init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func playSuccess() {
        playSystemSound(.success)
        createHapticFeedback(.success)
    }
    
    func playCheer() {
        playSystemSound(.cheer)
        createHapticFeedback(.success)
    }
    
    func playWhoosh() {
        playSystemSound(.whoosh)
        createHapticFeedback(.light)
    }
    
    func playPop() {
        playSystemSound(.pop)
        createHapticFeedback(.light)
    }
    
    private func playSystemSound(_ sound: SoundType) {
        // Generate simple tones using AVAudioEngine for different sound effects
        // This is a simplified implementation - you could add actual sound files
        
        switch sound {
        case .success:
            AudioServicesPlaySystemSound(1407) // Success sound
        case .cheer:
            AudioServicesPlaySystemSound(1108) // Cheer sound
        case .whoosh:
            AudioServicesPlaySystemSound(1104) // Whoosh sound
        case .pop:
            AudioServicesPlaySystemSound(1105) // Pop sound
        }
    }
    
    private func createHapticFeedback(_ type: HapticType) {
        let impactFeedback = UIImpactFeedbackGenerator(style: type.style)
        impactFeedback.impactOccurred()
    }
    
    enum SoundType {
        case success
        case cheer
        case whoosh
        case pop
    }
    
    enum HapticType {
        case light
        case medium
        case heavy
        case success
        case warning
        case error
        
        var style: UIImpactFeedbackGenerator.FeedbackStyle {
            switch self {
            case .light:
                return .light
            case .medium:
                return .medium
            case .heavy:
                return .heavy
            case .success, .warning, .error:
                return .medium
            }
        }
    }
}

// Extension to create notification feedback
extension SoundEffectPlayer {
    func createNotificationFeedback(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(type)
    }
} 