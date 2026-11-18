//
//  ShutterSoundService.swift
//  Film Camera
//

import AudioToolbox
import UIKit
import AVFoundation

/// Manages tactile analog mechanical shutter sounds and synchronized haptic feedback.
final class ShutterSoundService: @unchecked Sendable {
    static let shared = ShutterSoundService()

    private var audioPlayer: AVAudioPlayer?
    private var isAudioConfigured = false

    private init() {
        configureAudioSession()
        preloadSound()
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, options: [.mixWithOthers])
            try session.setActive(true)
            isAudioConfigured = true
        } catch {
            print("Failed to configure audio session for shutter sound: \(error)")
        }
    }

    private func preloadSound() {
        if let url = Bundle.main.url(forResource: "analog_shutter", withExtension: "wav") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
            } catch {
                print("Failed to load analog shutter sound: \(error)")
            }
        }
    }

    /// Plays authentic analog mechanical shutter sound and triggers multi-stage mechanical haptics.
    func playShutterEffect() {
        // 1. Play custom mechanical analog sound if available
        if let player = audioPlayer {
            player.currentTime = 0
            player.play()
        } else {
            // High-fidelity fallback to iOS system camera shutter click sound ID 1108
            AudioServicesPlaySystemSound(1108)
        }

        // 2. Multi-stage mechanical haptic feedback:
        // Stage A: Heavy shutter release impact
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()

        // Stage B: Film advance motor / mirror reset recoil (80ms later)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let recoil = UIImpactFeedbackGenerator(style: .medium)
            recoil.impactOccurred()
        }

        // Stage C: Final shutter blade lock (220ms later)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            let lock = UIImpactFeedbackGenerator(style: .light)
            lock.impactOccurred()
        }
    }

    /// Plays crisp timer tick sound and haptic pulse matching native iOS camera timer.
    func playTimerTick(isFinalRapid: Bool = false) {
        // Multi-tier crisp haptics matching iOS timer
        let generator = UIImpactFeedbackGenerator(style: isFinalRapid ? .rigid : .medium)
        generator.prepare()
        generator.impactOccurred()

        // Crisp audio tick (System Sound 1057 = keyboard/timer click)
        AudioServicesPlaySystemSound(1057)
    }
}
