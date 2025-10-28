import Foundation
import UserNotifications
import Combine

@MainActor
class NotificationManager: ObservableObject {
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    init() {
        // Defer heavy authorization check
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.checkAuthorizationStatus()
        }
    }
    
    func requestNotificationPermissionIfNeeded() {
        if authorizationStatus == .notDetermined {
            requestNotificationPermission()
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                if granted {
                    self?.authorizationStatus = .authorized
                } else {
                    self?.authorizationStatus = .denied
                }
            }
        }
    }
    
    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            let status = settings.authorizationStatus
            Task { @MainActor in
                self?.authorizationStatus = status
            }
        }
    }
    
    func schedulePrayerNotifications(for prayerTimes: [PrayerTime], settings: AppSettings) {
        guard authorizationStatus == .authorized else { return }
        
        // Cancel existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        for prayer in prayerTimes {
            // Get the notification state for this specific prayer
            let notificationState = settings.getPrayerNotificationState(for: prayer.name)
            
            let content = UNMutableNotificationContent()
            content.title = "Prayer Time"
            content.body = "It's time for \(prayer.name) prayer"
            
            // Configure notification based on state
            switch notificationState {
            case .off:
                // Don't schedule notification at all
                continue
            case .vibrate:
                // Silent notification (no sound)
                content.sound = nil
            case .sound:
                // Full notification with sound
                if settings.azanEnabled {
                    content.sound = UNNotificationSound(named: UNNotificationSoundName("azan_notification.mp3"))
                } else {
                    content.sound = UNNotificationSound.default
                }
            }
            
            content.categoryIdentifier = "PRAYER_NOTIFICATION"
            
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: prayer.time)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: prayer.name, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification for \(prayer.name): \(error)")
                }
            }
        }
        
        // Schedule 5-minute reminder notifications if enabled
        scheduleReminderNotifications(for: prayerTimes, settings: settings)
    }
    
    private func scheduleReminderNotifications(for prayerTimes: [PrayerTime], settings: AppSettings) {
        guard settings.reminderEnabled else { return }
        
        for prayer in prayerTimes {
            let reminderTime = prayer.time.addingTimeInterval(-300) // 5 minutes before
            
            let content = UNMutableNotificationContent()
            content.title = "Prayer Reminder"
            content.body = "\(prayer.name) prayer in 5 minutes"
            content.sound = UNNotificationSound.default
            
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: reminderTime)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: "\(prayer.name)_reminder", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling reminder for \(prayer.name): \(error)")
                }
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
