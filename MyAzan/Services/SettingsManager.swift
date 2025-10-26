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
}
