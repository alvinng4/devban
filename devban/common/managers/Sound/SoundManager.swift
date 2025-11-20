#if targetEnvironment(macCatalyst)
    import AVFoundation

    /// Manages sound effects for macCatalyst environment.
    ///
    /// Provides methods to play audio feedback using AVAudioPlayer,
    /// respecting user preferences for sound effects.
    final class SoundManager
    {
        /// Shared singleton instance
        static let shared = SoundManager()

        private init() {}

        var player: AVAudioPlayer?

        /// Plays a success sound effect if enabled in user settings.
        @MainActor
        func playSuccessSound()
        {
            guard DevbanUserContainer.shared.getSoundEffectSetting() else { return }

            guard let url = Bundle.main.url(forResource: "payment_success", withExtension: "caf")
            else
            {
                print("payment_success.caf audio file not found")
                return
            }

            do
            {
                player = try AVAudioPlayer(contentsOf: url)
                player?.play()
            }
            catch
            {
                print("Error playing sound: \(error.localizedDescription)")
            }
        }
    }
#else
    import AudioToolbox

    /// Manages sound effects for iOS environment.
    ///
    /// Provides methods to play system sound feedback using AudioToolbox,
    /// respecting user preferences for sound effects.
    final class SoundManager
    {
        /// Shared singleton instance
        static let shared = SoundManager()

        private init() {}

        /// Plays a success system sound if enabled in user settings.
        @MainActor
        func playSuccessSound()
        {
            guard DevbanUserContainer.shared.getSoundEffectSetting() else { return }

            AudioServicesPlaySystemSound(1407)
        }
    }
#endif
