import Foundation
import AVFoundation
import Combine

class AudioManager: ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    @Published var isPlaying = false
    
    init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func playAzan(voice: AzanVoice) {
        guard UserDefaults.standard.bool(forKey: "azanEnabled") else { return }
        
        guard let url = Bundle.main.url(forResource: voice.fileName.replacingOccurrences(of: ".mp3", with: ""), withExtension: "mp3") else {
            print("Audio file not found: \(voice.fileName)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            
            DispatchQueue.main.async {
                self.isPlaying = true
            }
        } catch {
            print("Error playing audio: \(error)")
        }
    }
    
    func stopAzan() {
        audioPlayer?.stop()
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
}

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Audio player decode error: \(error?.localizedDescription ?? "Unknown error")")
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
}
