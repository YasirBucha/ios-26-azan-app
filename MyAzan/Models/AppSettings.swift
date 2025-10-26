import Foundation
import Combine

class AppSettings: ObservableObject {
    @Published var azanEnabled: Bool {
        didSet {
            UserDefaults.standard.set(azanEnabled, forKey: "azanEnabled")
        }
    }
    
    @Published var selectedVoice: AzanVoice {
        didSet {
            UserDefaults.standard.set(selectedVoice.rawValue, forKey: "selectedVoice")
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
        self.selectedVoice = AzanVoice(rawValue: UserDefaults.standard.string(forKey: "selectedVoice") ?? "makkah") ?? .makkah
        self.liveActivityEnabled = UserDefaults.standard.bool(forKey: "liveActivityEnabled")
        self.reminderEnabled = UserDefaults.standard.bool(forKey: "reminderEnabled")
    }
}

enum AzanVoice: String, CaseIterable {
    case makkah = "makkah"
    case madinah = "madinah"
    case cairo = "cairo"
    
    var displayName: String {
        switch self {
        case .makkah: return "Makkah"
        case .madinah: return "Madinah"
        case .cairo: return "Cairo"
        }
    }
    
    var fileName: String {
        return "azan_\(rawValue).mp3"
    }
}
