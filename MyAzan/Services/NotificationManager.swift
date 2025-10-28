import Foundation
import UserNotifications
import Combine
import EventKit

@MainActor
class NotificationManager: ObservableObject {
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    private let eventStore = EKEventStore()
    
    init() {
        setupNotificationCategories()
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
                    self?.setupNotificationCategories()
                } else {
                    self?.authorizationStatus = .denied
                }
            }
        }
    }
    
    private func setupNotificationCategories() {
        let prayerCategory = UNNotificationCategory(
            identifier: "PRAYER_NOTIFICATION",
            actions: [],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([prayerCategory])
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
                // Check if we should use vibration only during meetings
                if settings.vibrationOnlyDuringMeetings && checkIfInMeetingAtTime(prayer.time) {
                    // Silent notification (vibration only) during meetings
                    content.sound = nil
                } else {
                    // Full notification with sound
                    if settings.azanEnabled {
                        content.sound = UNNotificationSound(named: UNNotificationSoundName("azan_notification.mp3"))
                    } else {
                        content.sound = UNNotificationSound.default
                    }
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
            
            // Check if we should use vibration only during meetings
            if settings.vibrationOnlyDuringMeetings && checkIfInMeetingAtTime(reminderTime) {
                // Silent notification (vibration only) during meetings
                content.sound = nil
            } else {
                content.sound = UNNotificationSound.default
            }
            
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
    
    // MARK: - Calendar Integration Methods
    private func checkIfInMeetingAtTime(_ date: Date) -> Bool {
        guard EKEventStore.authorizationStatus(for: .event) == .fullAccess else { return false }
        
        // Create a predicate to find events at the given time
        let predicate = eventStore.predicateForEvents(
            withStart: date,
            end: date,
            calendars: nil
        )
        
        let events = eventStore.events(matching: predicate)
        
        // Check if any event is happening at the given time
        for event in events {
            if event.startDate <= date && event.endDate >= date {
                // Check if this looks like a meeting
                if !event.isAllDay && (event.hasAttendees || event.title.lowercased().contains("meeting") || event.title.lowercased().contains("call")) {
                    return true
                }
            }
        }
        
        return false
    }
}
