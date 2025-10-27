import Foundation
import Combine

@MainActor
class SettingsManager: ObservableObject {
    @Published var settings = AppSettings()
    
    init() {
        // Initialize with default settings
    }
    
    func updateAzanEnabled(_ enabled: Bool) {
        settings.azanEnabled = enabled
    }
    
    func updateSelectedAudioFile(_ fileId: UUID?) {
        settings.selectedAudioFileId = fileId
    }
    
    func updateUseDefaultAudio(_ useDefault: Bool) {
        settings.useDefaultAudio = useDefault
    }
    
    func updateLiveActivityEnabled(_ enabled: Bool) {
        settings.liveActivityEnabled = enabled
    }
    
    func updateReminderEnabled(_ enabled: Bool) {
        settings.reminderEnabled = enabled
    }
    
    // Individual prayer sound management
    func updateFajrSoundEnabled(_ enabled: Bool) {
        settings.fajrSoundEnabled = enabled
    }
    
    func updateDhuhrSoundEnabled(_ enabled: Bool) {
        settings.dhuhrSoundEnabled = enabled
    }
    
    func updateAsrSoundEnabled(_ enabled: Bool) {
        settings.asrSoundEnabled = enabled
    }
    
    func updateMaghribSoundEnabled(_ enabled: Bool) {
        settings.maghribSoundEnabled = enabled
    }
    
    func updateIshaSoundEnabled(_ enabled: Bool) {
        settings.ishaSoundEnabled = enabled
    }
    
    // Bulk operations
    func enableAllPrayerSounds() {
        settings.enableAllPrayerSounds()
    }
    
    func disableAllPrayerSounds() {
        settings.disableAllPrayerSounds()
    }
}
