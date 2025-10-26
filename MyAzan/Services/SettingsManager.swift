import Foundation
import Combine

class SettingsManager: ObservableObject {
    @Published var settings = AppSettings()
    
    init() {
        // Initialize with default settings
    }
    
    func updateAzanEnabled(_ enabled: Bool) {
        settings.azanEnabled = enabled
    }
    
    func updateSelectedVoice(_ voice: AzanVoice) {
        settings.selectedVoice = voice
    }
    
    func updateLiveActivityEnabled(_ enabled: Bool) {
        settings.liveActivityEnabled = enabled
    }
    
    func updateReminderEnabled(_ enabled: Bool) {
        settings.reminderEnabled = enabled
    }
}
