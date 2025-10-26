import Foundation
import AVFoundation
import Combine

class AudioManager: NSObject, ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    @Published var isPlaying = false
    private let audioFileManager = AudioFileManager.shared
    
    override init() {
        super.init()
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
    
    func playAzan(useDefault: Bool = true, customFileId: UUID? = nil) {
        guard UserDefaults.standard.bool(forKey: "azanEnabled") else { return }
        
        var url: URL?
        
        if useDefault {
            url = audioFileManager.getDefaultAudioURL()
        } else if let fileId = customFileId,
                  let customFile = audioFileManager.customAudioFiles.first(where: { $0.id == fileId }) {
            url = audioFileManager.getAudioURL(for: customFile)
        }
        
        guard let audioURL = url else {
            print("Audio file not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
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
