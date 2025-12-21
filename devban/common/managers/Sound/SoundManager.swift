import AudioToolbox
import AVFoundation
import SwiftUI

/// A singleton manager class responsible for handling application sound effects.
///
/// This class manages the playback of custom audio files and system sounds. It checks the user's
/// sound preferences via `DevbanUserContainer` before playing any audio. It also handles
/// platform-specific logic, distinguishing between iOS (System Sound Services) and macOS Catalyst (AVAudioPlayer).
final class SoundManager
{
    /// The shared singleton instance of `SoundManager`.
    static let shared = SoundManager()

    private init() {}

    /// A dictionary to cache and retain strong references to `AVAudioPlayer` instances.
    ///
    /// - Note: Without this cache, the local `AVAudioPlayer` variable in `playCustomSound` would be
    /// deallocated immediately after the function scope ends, causing the sound to stop prematurely.
    private var customSoundPlayers: [String: AVAudioPlayer] = [:]

    /// A dedicated player instance for the macOS success sound to ensure it is retained during playback.
    private var successSoundPlayer: AVAudioPlayer?

    /// Plays a custom sound file located in the main bundle.
    ///
    /// This method first checks if sound effects are enabled in `DevbanUserContainer`.
    /// If enabled, it attempts to locate and play the specified audio file.
    ///
    /// - Parameters:
    ///   - filename: The name of the resource file.
    ///   - ext: The file extension (e.g., "mp3", "caf").
    ///   - volume: The playback volume, ranging from 0.0 to 1.0. Defaults to 1.0.
    @MainActor
    private func playCustomSound(filename: String, ext: String, volume: Float = 1.0)
    {
        // Check user preference setting
        guard DevbanUserContainer.shared.getSoundEffectSetting() else { return }

        guard let url = Bundle.main.url(forResource: filename, withExtension: ext)
        else
        {
            print("Audio file \(filename).\(ext) not found")
            return
        }

        do
        {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = volume
            player.prepareToPlay()
            player.play()

            // Retain the player instance to prevent deallocation
            customSoundPlayers[filename] = player
        }
        catch
        {
            print("Failed to play sound: \(error)")
        }
    }

    /// Plays the primary sword slash sound effect at 10% volume.
    @MainActor
    func playSlashSound1()
    {
        playCustomSound(filename: "SwordSound1", ext: "mp3", volume: 0.1)
    }

    /// Plays the secondary sword slash sound effect at 20% volume.
    @MainActor
    func playSlashSound2()
    {
        playCustomSound(filename: "SwordSound2", ext: "mp3", volume: 0.2)
    }

    /// Plays a success or completion sound effect.
    ///
    /// - Platform Specific Behavior:
    ///   - **macOS Catalyst**: Plays a custom "payment_success.caf" file using `AVAudioPlayer`.
    ///   - **iOS**: Uses `AudioServicesPlaySystemSound` to play system sound ID 1407.
    @MainActor
    func playSuccessSound()
    {
        guard DevbanUserContainer.shared.getSoundEffectSetting() else { return }

        #if targetEnvironment(macCatalyst)
            // macOS uses a custom sound file for better desktop experience
            if let url = Bundle.main.url(forResource: "payment_success", withExtension: "caf")
            {
                try? successSoundPlayer = AVAudioPlayer(contentsOf: url)
                successSoundPlayer?.play()
            }
        #else
            // iOS uses the standard system sound for consistency
            AudioServicesPlaySystemSound(1407)
        #endif
    }
}
