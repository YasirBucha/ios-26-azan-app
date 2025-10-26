import Foundation
import UserNotifications
import Combine

class NotificationManager: ObservableObject {
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    init() {
        checkAuthorizationStatus()
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
            DispatchQueue.main.async {
                self?.authorizationStatus = settings.authorizationStatus
            }
        }
    }
    
    func schedulePrayerNotifications(for prayerTimes: [PrayerTime]) {
        guard authorizationStatus == .authorized else { return }
        
        // Cancel existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        for prayer in prayerTimes {
            let content = UNMutableNotificationContent()
            content.title = "Prayer Time"
            content.body = "It's time for \(prayer.name) prayer"
            content.sound = UNNotificationSound(named: UNNotificationSoundName("azan_notification.wav"))
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
        scheduleReminderNotifications(for: prayerTimes)
    }
    
    private func scheduleReminderNotifications(for prayerTimes: [PrayerTime]) {
        let settings = UserDefaults.standard.bool(forKey: "reminderEnabled")
        guard settings else { return }
        
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
