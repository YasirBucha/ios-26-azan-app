import Foundation
import Combine

class AppSettings: ObservableObject {
    @Published var azanEnabled: Bool {
        didSet {
            UserDefaults.standard.set(azanEnabled, forKey: "azanEnabled")
        }
    }
    
    @Published var selectedAudioFileId: UUID? {
        didSet {
            if let id = selectedAudioFileId?.uuidString {
                UserDefaults.standard.set(id, forKey: "selectedAudioFileId")
            } else {
                UserDefaults.standard.removeObject(forKey: "selectedAudioFileId")
            }
        }
    }
    
    @Published var useDefaultAudio: Bool {
        didSet {
            UserDefaults.standard.set(useDefaultAudio, forKey: "useDefaultAudio")
        }
    }
    
    @Published var liveActivityEnabled: Bool {
        didSet {
            UserDefaults.standard.set(liveActivityEnabled, forKey: "liveActivityEnabled")
        }
    }
    
    @Published var reminderEnabled: Bool {
        didSet {
            UserDefaults.standard.set(reminderEnabled, forKey: "reminderEnabled")
        }
    }
    
    init() {
        self.azanEnabled = UserDefaults.standard.bool(forKey: "azanEnabled")
        self.useDefaultAudio = UserDefaults.standard.object(forKey: "useDefaultAudio") as? Bool ?? true
        
        if let idString = UserDefaults.standard.string(forKey: "selectedAudioFileId"),
           let id = UUID(uuidString: idString) {
            self.selectedAudioFileId = id
        }
        
        self.liveActivityEnabled = UserDefaults.standard.bool(forKey: "liveActivityEnabled")
        self.reminderEnabled = UserDefaults.standard.bool(forKey: "reminderEnabled")
    }
}
