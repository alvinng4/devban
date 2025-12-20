import AVFoundation
import AudioToolbox
import SwiftUI

final class SoundManager {
    static let shared = SoundManager()
    private init() {}
    
    // used to cache custom sound players
    private var customSoundPlayers: [String: AVAudioPlayer] = [:]
    
    // used for macOS success sound
    private var successSoundPlayer: AVAudioPlayer?

    @MainActor
    private func playCustomSound(filename: String, ext: String) {
        guard DevbanUserContainer.shared.getSoundEffectSetting() else { return }
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: ext) else {
            print("Audio file \(filename).\(ext) not found")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.play()
            customSoundPlayers[filename] = player
        } catch {
            print("Failed to play sound: \(error)")
        }
    }
    
    @MainActor
    func playSlashSound1() {
        playCustomSound(filename: "SwordSound1", ext: "mp3")
    }
    
    @MainActor
    func playSlashSound2() {
        playCustomSound(filename: "SwordSound2", ext: "mp3")
    }

    @MainActor
    func playSuccessSound() {
        guard DevbanUserContainer.shared.getSoundEffectSetting() else { return }
        
        #if targetEnvironment(macCatalyst)
            // macOS use custom sound
            if let url = Bundle.main.url(forResource: "payment_success", withExtension: "caf") {
                try? successSoundPlayer = AVAudioPlayer(contentsOf: url)
                successSoundPlayer?.play()
            }
        #else
            // iOS use system sound
            AudioServicesPlaySystemSound(1407)
        #endif
    }
}
