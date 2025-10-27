import Foundation
import AVFoundation
import AudioToolbox
import Combine

class AudioManager: NSObject, ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    @Published var isPlaying = false
    @Published var currentlyPlayingId: UUID?
    private let audioFileManager = AudioFileManager.shared
    private let audioSession = AVAudioSession.sharedInstance()
    private var hasConfiguredSession = false
    private var isSessionActive = false
    
    override init() {
        super.init()
    }
    
    private func configureAudioSessionIfNeeded() {
        guard !hasConfiguredSession else { return }
        do {
            try audioSession.setCategory(
                .playback,
                mode: .default,
                options: [.allowBluetoothHFP, .allowBluetoothA2DP, .mixWithOthers]
            )
            hasConfiguredSession = true
            print("✅ Audio session category configured")
        } catch {
            print("❌ Failed to configure audio session category: \(error)")
            
            // Fallback: try ambient if playback fails
            do {
                try audioSession.setCategory(.ambient)
                hasConfiguredSession = true
                print("✅ Audio session configured successfully (ambient fallback)")
            } catch {
                print("❌ Failed to configure audio session (ambient fallback): \(error)")
            }
        }
    }

    private func activateAudioSessionIfNeeded() {
        configureAudioSessionIfNeeded()
        guard hasConfiguredSession, !isSessionActive else { return }
        do {
            try audioSession.setActive(true)
            isSessionActive = true
            print("✅ Audio session activated")
        } catch {
            print("❌ Failed to activate audio session: \(error)")
        }
    }

    private func deactivateAudioSessionIfPossible() {
        guard isSessionActive else { return }
        do {
            try audioSession.setActive(false, options: [.notifyOthersOnDeactivation])
            isSessionActive = false
            print("✅ Audio session deactivated")
        } catch {
            print("❌ Failed to deactivate audio session: \(error)")
        }
    }
    
    func playAzan(useDefault: Bool = true, customFileId: UUID? = nil) {
        guard UserDefaults.standard.bool(forKey: "azanEnabled") else { 
            print("❌ Azan is disabled in settings")
            return 
        }
        
        print("🎵 Attempting to play azan - useDefault: \(useDefault), customFileId: \(customFileId?.uuidString ?? "nil")")
        
        var url: URL?
        
        if useDefault {
            url = audioFileManager.getDefaultAudioURL()
        } else if let fileId = customFileId,
                  let customFile = audioFileManager.customAudioFiles.first(where: { $0.id == fileId }) {
            url = audioFileManager.getAudioURL(for: customFile)
        }
        
        guard let audioURL = url else {
            print("❌ Audio file not found - using system sound fallback")
            playSystemSoundFallback()
            return
        }
        
        print("🎵 Audio file found at: \(audioURL.path)")
        print("🎵 File exists: \(FileManager.default.fileExists(atPath: audioURL.path))")

        activateAudioSessionIfNeeded()
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.delegate = self
            audioPlayer?.volume = 1.0
            
            let success = audioPlayer?.play() ?? false
            print("🎵 Audio player created and play() called - success: \(success)")
            
            DispatchQueue.main.async {
                self.isPlaying = success
            }
        } catch {
            print("❌ Error playing audio: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
            print("🔄 Falling back to system sound")
            playSystemSoundFallback()
        }
    }
    
    func stopAzan() {
        audioPlayer?.stop()
        DispatchQueue.main.async {
            self.isPlaying = false
            self.currentlyPlayingId = nil
        }
        deactivateAudioSessionIfPossible()
    }
    
    // MARK: - Preview Functions
    func previewAudio(useDefault: Bool = true, customFileId: UUID? = nil) {
        // Stop any currently playing audio
        stopAzan()
        activateAudioSessionIfNeeded()
        
        var url: URL?
        var playingId: UUID?
        
        if useDefault {
            url = audioFileManager.getDefaultAudioURL()
            playingId = UUID(uuidString: "default") // Use a special UUID for default
        } else if let fileId = customFileId,
                  let customFile = audioFileManager.customAudioFiles.first(where: { $0.id == fileId }) {
            url = audioFileManager.getAudioURL(for: customFile)
            playingId = fileId
        }
        
        guard let audioURL = url, let id = playingId else {
            print("Audio file not found for preview")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            
            DispatchQueue.main.async {
                self.isPlaying = true
                self.currentlyPlayingId = id
            }
        } catch {
            print("Error playing audio preview: \(error)")
        }
    }
    
    func isCurrentlyPlaying(_ id: UUID) -> Bool {
        return currentlyPlayingId == id && isPlaying
    }
    
    func isCurrentlyPlayingDefault() -> Bool {
        return currentlyPlayingId == UUID(uuidString: "default") && isPlaying
    }
    
    // MARK: - System Sound Fallback
    private func playSystemSoundFallback() {
        print("🔔 Playing system sound fallback")
        
        // Play a sequence of system sounds to simulate azan
        let sounds: [SystemSoundID] = [1005, 1006, 1007] // Different notification sounds
        
        for (index, soundID) in sounds.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.5) {
                AudioServicesPlaySystemSound(soundID)
            }
        }
        
        // Set playing state for UI feedback
        DispatchQueue.main.async {
            self.isPlaying = true
        }
        
        // Stop playing state after sounds finish
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isPlaying = false
            self.deactivateAudioSessionIfPossible()
        }
    }
}

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.currentlyPlayingId = nil
        }
        deactivateAudioSessionIfPossible()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Audio player decode error: \(error?.localizedDescription ?? "Unknown error")")
        DispatchQueue.main.async {
            self.isPlaying = false
            self.currentlyPlayingId = nil
        }
        deactivateAudioSessionIfPossible()
    }
}
