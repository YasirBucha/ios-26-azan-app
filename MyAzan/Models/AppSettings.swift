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
    
    // Individual prayer sound settings
    @Published var fajrSoundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(fajrSoundEnabled, forKey: "fajrSoundEnabled")
        }
    }
    
    @Published var dhuhrSoundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(dhuhrSoundEnabled, forKey: "dhuhrSoundEnabled")
        }
    }
    
    @Published var asrSoundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(asrSoundEnabled, forKey: "asrSoundEnabled")
        }
    }
    
    @Published var maghribSoundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(maghribSoundEnabled, forKey: "maghribSoundEnabled")
        }
    }
    
    @Published var ishaSoundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(ishaSoundEnabled, forKey: "ishaSoundEnabled")
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
        
        // Initialize individual prayer sound settings (default to true for all prayers)
        self.fajrSoundEnabled = UserDefaults.standard.object(forKey: "fajrSoundEnabled") as? Bool ?? true
        self.dhuhrSoundEnabled = UserDefaults.standard.object(forKey: "dhuhrSoundEnabled") as? Bool ?? true
        self.asrSoundEnabled = UserDefaults.standard.object(forKey: "asrSoundEnabled") as? Bool ?? true
        self.maghribSoundEnabled = UserDefaults.standard.object(forKey: "maghribSoundEnabled") as? Bool ?? true
        self.ishaSoundEnabled = UserDefaults.standard.object(forKey: "ishaSoundEnabled") as? Bool ?? true
    }
    
    // Helper methods for bulk operations
    func enableAllPrayerSounds() {
        fajrSoundEnabled = true
        dhuhrSoundEnabled = true
        asrSoundEnabled = true
        maghribSoundEnabled = true
        ishaSoundEnabled = true
    }
    
    func disableAllPrayerSounds() {
        fajrSoundEnabled = false
        dhuhrSoundEnabled = false
        asrSoundEnabled = false
        maghribSoundEnabled = false
        ishaSoundEnabled = false
    }
    
    func isPrayerSoundEnabled(for prayerName: String) -> Bool {
        switch prayerName.lowercased() {
        case "fajr":
            return fajrSoundEnabled
        case "dhuhr":
            return dhuhrSoundEnabled
        case "asr":
            return asrSoundEnabled
        case "maghrib":
            return maghribSoundEnabled
        case "isha":
            return ishaSoundEnabled
        default:
            return true
        }
    }
}
