import Foundation
import Combine

enum PrayerNotificationState: String, CaseIterable {
    case off = "off"
    case vibrate = "vibrate"
    case sound = "sound"
    
    var iconName: String {
        switch self {
        case .off:
            return "bell.slash"
        case .vibrate:
            return "bell.badge"
        case .sound:
            return "bell.fill"
        }
    }
    
    var color: String {
        switch self {
        case .off:
            return "gray"
        case .vibrate:
            return "orange"
        case .sound:
            return "blue"
        }
    }
}

@MainActor
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
    
    @Published var vibrationOnlyDuringMeetings: Bool {
        didSet {
            UserDefaults.standard.set(vibrationOnlyDuringMeetings, forKey: "vibrationOnlyDuringMeetings")
        }
    }
    
    @Published var appVolume: Float {
        didSet {
            UserDefaults.standard.set(appVolume, forKey: "appVolume")
        }
    }
    
    // Individual prayer notification settings
    @Published var fajrNotificationState: PrayerNotificationState {
        didSet {
            UserDefaults.standard.set(fajrNotificationState.rawValue, forKey: "fajrNotificationState")
        }
    }
    
    @Published var dhuhrNotificationState: PrayerNotificationState {
        didSet {
            UserDefaults.standard.set(dhuhrNotificationState.rawValue, forKey: "dhuhrNotificationState")
        }
    }
    
    @Published var asrNotificationState: PrayerNotificationState {
        didSet {
            UserDefaults.standard.set(asrNotificationState.rawValue, forKey: "asrNotificationState")
        }
    }
    
    @Published var maghribNotificationState: PrayerNotificationState {
        didSet {
            UserDefaults.standard.set(maghribNotificationState.rawValue, forKey: "maghribNotificationState")
        }
    }
    
    @Published var ishaNotificationState: PrayerNotificationState {
        didSet {
            UserDefaults.standard.set(ishaNotificationState.rawValue, forKey: "ishaNotificationState")
        }
    }
    
    init() {
        self.azanEnabled = UserDefaults.standard.object(forKey: "azanEnabled") as? Bool ?? true
        self.useDefaultAudio = UserDefaults.standard.object(forKey: "useDefaultAudio") as? Bool ?? true
        
        if let idString = UserDefaults.standard.string(forKey: "selectedAudioFileId"),
           let id = UUID(uuidString: idString) {
            self.selectedAudioFileId = id
        }
        
        self.liveActivityEnabled = UserDefaults.standard.object(forKey: "liveActivityEnabled") as? Bool ?? true
        self.reminderEnabled = UserDefaults.standard.object(forKey: "reminderEnabled") as? Bool ?? true
        self.vibrationOnlyDuringMeetings = UserDefaults.standard.object(forKey: "vibrationOnlyDuringMeetings") as? Bool ?? false
        
        // Initialize app volume (default to 0.8)
        self.appVolume = UserDefaults.standard.object(forKey: "appVolume") as? Float ?? 0.8
        
        // Initialize individual prayer notification settings (default to sound for all prayers)
        self.fajrNotificationState = PrayerNotificationState(rawValue: UserDefaults.standard.string(forKey: "fajrNotificationState") ?? "sound") ?? .sound
        self.dhuhrNotificationState = PrayerNotificationState(rawValue: UserDefaults.standard.string(forKey: "dhuhrNotificationState") ?? "sound") ?? .sound
        self.asrNotificationState = PrayerNotificationState(rawValue: UserDefaults.standard.string(forKey: "asrNotificationState") ?? "sound") ?? .sound
        self.maghribNotificationState = PrayerNotificationState(rawValue: UserDefaults.standard.string(forKey: "maghribNotificationState") ?? "sound") ?? .sound
        self.ishaNotificationState = PrayerNotificationState(rawValue: UserDefaults.standard.string(forKey: "ishaNotificationState") ?? "sound") ?? .sound
    }
    
    // Helper methods for bulk operations
    func setAllPrayerNotifications(to state: PrayerNotificationState) {
        print("🔄 Setting all prayer notifications to: \(state.rawValue)")
        fajrNotificationState = state
        dhuhrNotificationState = state
        asrNotificationState = state
        maghribNotificationState = state
        ishaNotificationState = state
        print("✅ All prayer notifications updated to: \(state.rawValue)")
    }
    
    func getPrayerNotificationState(for prayerName: String) -> PrayerNotificationState {
        switch prayerName.lowercased() {
        case "fajr":
            return fajrNotificationState
        case "dhuhr", "zuhr":
            return dhuhrNotificationState
        case "asr":
            return asrNotificationState
        case "maghrib":
            return maghribNotificationState
        case "isha":
            return ishaNotificationState
        default:
            return .sound
        }
    }
    
    func setPrayerNotificationState(for prayerName: String, to state: PrayerNotificationState) {
        switch prayerName.lowercased() {
        case "fajr":
            fajrNotificationState = state
        case "dhuhr", "zuhr":
            dhuhrNotificationState = state
        case "asr":
            asrNotificationState = state
        case "maghrib":
            maghribNotificationState = state
        case "isha":
            ishaNotificationState = state
        default:
            break
        }
    }
}
