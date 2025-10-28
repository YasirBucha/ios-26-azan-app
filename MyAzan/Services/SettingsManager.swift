import Foundation
import Combine

@MainActor
class SettingsManager: ObservableObject {
    @Published var settings = AppSettings()
    
    init() {
        // Initialize with default settings
        // Forward AppSettings changes to SettingsManager
        settings.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
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
    
    func updateVibrationOnlyDuringMeetings(_ enabled: Bool) {
        settings.vibrationOnlyDuringMeetings = enabled
    }
    
    // Individual prayer notification management
    func updateFajrNotificationState(_ state: PrayerNotificationState) {
        settings.fajrNotificationState = state
    }
    
    func updateDhuhrNotificationState(_ state: PrayerNotificationState) {
        settings.dhuhrNotificationState = state
    }
    
    func updateAsrNotificationState(_ state: PrayerNotificationState) {
        settings.asrNotificationState = state
    }
    
    func updateMaghribNotificationState(_ state: PrayerNotificationState) {
        settings.maghribNotificationState = state
    }
    
    func updateIshaNotificationState(_ state: PrayerNotificationState) {
        settings.ishaNotificationState = state
    }
    
    // Bulk operations
    func setAllPrayerNotifications(to state: PrayerNotificationState) {
        settings.setAllPrayerNotifications(to: state)
    }
    
    func getPrayerNotificationState(for prayerName: String) -> PrayerNotificationState {
        return settings.getPrayerNotificationState(for: prayerName)
    }
    
    func setPrayerNotificationState(for prayerName: String, to state: PrayerNotificationState) {
        settings.setPrayerNotificationState(for: prayerName, to: state)
    }
}
