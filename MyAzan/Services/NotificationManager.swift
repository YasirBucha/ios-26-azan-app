import Foundation
import UserNotifications
import Combine
import EventKit

@MainActor
class NotificationManager: ObservableObject {
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    private var schedulingTask: Task<Void, Never>?
    private var lastScheduleSignature: NotificationScheduleSignature?
    private var lastScheduledPrayers: [ScheduledPrayer] = []
    private var lastSettingsSnapshot: NotificationSettingsSnapshot?
    static private(set) weak var current: NotificationManager?

    init() {
        NotificationManager.current = self
        PerformanceLogger.event("NotificationManager init")
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
        PerformanceLogger.event("Requesting notification permission")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                PerformanceLogger.event("Notification permission response (granted=\(granted))")
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
        PerformanceLogger.event("Setting notification categories")
        let prayerCategory = UNNotificationCategory(
            identifier: "PRAYER_NOTIFICATION",
            actions: [],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([prayerCategory])
    }
    
    private func checkAuthorizationStatus() {
        PerformanceLogger.event("Checking notification authorization status")
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            let status = settings.authorizationStatus
            Task { @MainActor in
                self?.authorizationStatus = status
                PerformanceLogger.event("Notification authorization status updated: \(status.rawValue)")
            }
        }
    }
    
    func schedulePrayerNotifications(for prayerTimes: [PrayerTime], settings: AppSettings, force: Bool = false) {
        guard authorizationStatus == .authorized else { return }

        let snapshot = settings.makeNotificationSnapshot()
        let scheduledPrayers = prayerTimes.map { ScheduledPrayer(name: $0.name, time: $0.time) }
        schedule(prayers: scheduledPrayers, snapshot: snapshot, force: force)
    }

    func cancelAllNotifications() {
        schedulingTask?.cancel()
        schedulingTask = nil
        lastScheduleSignature = nil
        lastScheduledPrayers = []
        lastSettingsSnapshot = nil
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func rescheduleAfterMeetingFetch() {
        guard let snapshot = lastSettingsSnapshot, !lastScheduledPrayers.isEmpty else { return }
        schedule(prayers: lastScheduledPrayers, snapshot: snapshot, force: true)
    }

    private func schedule(prayers: [ScheduledPrayer], snapshot: NotificationSettingsSnapshot, force: Bool) {
        let signature = NotificationScheduleSignature(prayers: prayers, settings: snapshot)

        if !force, lastScheduleSignature == signature {
            return
        }

        lastScheduleSignature = signature
        lastScheduledPrayers = prayers
        lastSettingsSnapshot = snapshot

        schedulingTask?.cancel()
        schedulingTask = Task.detached(priority: .utility) { [snapshot, prayers] in
            await NotificationScheduler.schedule(prayers: prayers, settings: snapshot)
        }
    }
}

private struct ScheduledPrayer: Sendable {
    let name: String
    let time: Date
}

private struct NotificationScheduleSignature: Equatable, Sendable {
    private let prayers: [PrayerSignature]
    private let azanEnabled: Bool
    private let reminderEnabled: Bool
    private let vibrationOnlyDuringMeetings: Bool
    private let prayerStates: [PrayerStateSignature]

    init(prayers: [ScheduledPrayer], settings: NotificationSettingsSnapshot) {
        self.prayers = prayers
            .map { PrayerSignature(name: $0.name.lowercased(), time: $0.time) }
            .sorted(by: { lhs, rhs in
                if lhs.name == rhs.name {
                    return lhs.time < rhs.time
                }
                return lhs.name < rhs.name
            })
        self.azanEnabled = settings.azanEnabled
        self.reminderEnabled = settings.reminderEnabled
        self.vibrationOnlyDuringMeetings = settings.vibrationOnlyDuringMeetings
        self.prayerStates = settings.allPrayerStates
            .map { PrayerStateSignature(name: $0.key.lowercased(), state: $0.value.rawValue) }
            .sorted { $0.name < $1.name }
    }

    static func == (lhs: NotificationScheduleSignature, rhs: NotificationScheduleSignature) -> Bool {
        lhs.prayers == rhs.prayers &&
        lhs.azanEnabled == rhs.azanEnabled &&
        lhs.reminderEnabled == rhs.reminderEnabled &&
        lhs.vibrationOnlyDuringMeetings == rhs.vibrationOnlyDuringMeetings &&
        lhs.prayerStates == rhs.prayerStates
    }

    private struct PrayerSignature: Equatable, Sendable {
        let name: String
        let time: Date
    }

    private struct PrayerStateSignature: Equatable, Sendable {
        let name: String
        let state: String
    }
}

struct NotificationSettingsSnapshot: Sendable {
    let azanEnabled: Bool
    let reminderEnabled: Bool
    let vibrationOnlyDuringMeetings: Bool
    private let prayerStates: [String: PrayerNotificationState]

    init(azanEnabled: Bool, reminderEnabled: Bool, vibrationOnlyDuringMeetings: Bool, prayerStates: [String: PrayerNotificationState]) {
        self.azanEnabled = azanEnabled
        self.reminderEnabled = reminderEnabled
        self.vibrationOnlyDuringMeetings = vibrationOnlyDuringMeetings
        self.prayerStates = prayerStates
    }

    func state(for prayerName: String) -> PrayerNotificationState {
        let key = prayerName.lowercased()
        return prayerStates[key] ?? .sound
    }

    var allPrayerStates: [String: PrayerNotificationState] {
        prayerStates
    }
}

private enum NotificationScheduler {
    static func schedule(prayers: [ScheduledPrayer], settings: NotificationSettingsSnapshot) async {
        guard !Task.isCancelled else { return }

        let notificationCenter = UNUserNotificationCenter.current()
        let existingIdentifiers = await notificationCenter.pendingRequestIdentifiers()
        var blueprints: [NotificationBlueprint] = []
        let relevantDates = relevantMeetingDates(prayers: prayers, includeReminders: settings.reminderEnabled)
        var meetingChecker: MeetingChecker? = nil
        var needsMeetingFetch = false

        if settings.vibrationOnlyDuringMeetings {
            if let cachedEvents = await MeetingAvailabilityCache.shared.cachedEvents(covering: relevantDates) {
                if !cachedEvents.isEmpty {
                    meetingChecker = MeetingChecker(events: cachedEvents)
                }
            } else {
                needsMeetingFetch = true
            }
        }
        let now = Date()

        for prayer in prayers {
            if Task.isCancelled { return }
            guard prayer.time > now else { continue }

            let state = settings.state(for: prayer.name)
            if state == .off { continue }

            let content = UNMutableNotificationContent()
            content.title = "Prayer Time"
            content.body = "It's time for \(prayer.name) prayer"
            content.categoryIdentifier = "PRAYER_NOTIFICATION"
            content.sound = sound(for: state, settings: settings, fireDate: prayer.time, meetingChecker: meetingChecker)

            let components = Calendar.current.dateComponents([.hour, .minute], from: prayer.time)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            blueprints.append(NotificationBlueprint(identifier: prayer.name, content: content, trigger: trigger))
        }

        guard settings.reminderEnabled else { return }

        for prayer in prayers {
            if Task.isCancelled { return }

            let reminderTime = prayer.time.addingTimeInterval(-300) // 5 minutes before
            guard reminderTime > now else { continue }

            let content = UNMutableNotificationContent()
            content.title = "Prayer Reminder"
            content.body = "\(prayer.name) prayer in 5 minutes"
            content.sound = meetingChecker?.isInMeeting(at: reminderTime) == true ? nil : UNNotificationSound.default

            let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            blueprints.append(NotificationBlueprint(identifier: "\(prayer.name)_reminder", content: content, trigger: trigger))
        }

        if Task.isCancelled { return }

        let desiredIdentifiers = Set(blueprints.map { $0.identifier })
        let identifiersToRemove = Set(existingIdentifiers).subtracting(desiredIdentifiers)

        if !identifiersToRemove.isEmpty {
            notificationCenter.removePendingNotificationRequests(withIdentifiers: Array(identifiersToRemove))
        }

        for blueprint in blueprints {
            if Task.isCancelled { return }
            let request = UNNotificationRequest(identifier: blueprint.identifier, content: blueprint.content, trigger: blueprint.trigger)
            notificationCenter.add(request) { error in
                if let error {
                    print("Error scheduling notification for \(blueprint.identifier): \(error.localizedDescription)")
                }
            }
        }

        if needsMeetingFetch {
            Task.detached(priority: .background) {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                let fetched = await MeetingAvailabilityCache.shared.prefetchEvents(covering: relevantDates)
                if fetched {
                    await MainActor.run {
                        NotificationManager.current?.rescheduleAfterMeetingFetch()
                    }
                }
            }
        }
    }

    private static func sound(for state: PrayerNotificationState, settings: NotificationSettingsSnapshot, fireDate: Date, meetingChecker: MeetingChecker?) -> UNNotificationSound? {
        switch state {
        case .off:
            return nil
        case .vibrate:
            return nil
        case .sound:
            if meetingChecker?.isInMeeting(at: fireDate) == true {
                return nil
            }
            return settings.azanEnabled ? UNNotificationSound(named: UNNotificationSoundName("azan_notification.mp3")) : UNNotificationSound.default
        }
    }
}

private struct NotificationBlueprint {
    let identifier: String
    let content: UNMutableNotificationContent
    let trigger: UNCalendarNotificationTrigger
}

private struct MeetingChecker {
    private let events: [MeetingEvent]

    init(events: [MeetingEvent]) {
        self.events = events
    }

    func isInMeeting(at date: Date) -> Bool {
        for event in events where event.startDate <= date && event.endDate >= date {
            if event.isAllDay { continue }
            if event.matchesMeetingCriteria {
                return true
            }
        }
        return false
    }
}

private struct MeetingEvent: Sendable {
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
    private let hasAttendees: Bool
    private let lowercasedTitle: String

    init(event: EKEvent) {
        self.startDate = event.startDate
        self.endDate = event.endDate
        self.isAllDay = event.isAllDay
        self.hasAttendees = event.hasAttendees
        self.lowercasedTitle = event.title?.lowercased() ?? ""
    }

    var matchesMeetingCriteria: Bool {
        hasAttendees || lowercasedTitle.contains("meeting") || lowercasedTitle.contains("call")
    }
}

private extension UNUserNotificationCenter {
    func pendingRequestIdentifiers() async -> [String] {
        await withCheckedContinuation { continuation in
            getPendingNotificationRequests { requests in
                let identifiers = requests.map { $0.identifier }
                continuation.resume(returning: identifiers)
            }
        }
    }
}

private actor MeetingAvailabilityCache {
    static let shared = MeetingAvailabilityCache()

    private let eventStore = EKEventStore()
    private var cachedEvents: [MeetingEvent] = []
    private var cachedInterval: DateInterval?
    private var lastFetch: Date?
    private var isFetching = false

    func cachedEvents(covering dates: [Date]) -> [MeetingEvent]? {
        guard !dates.isEmpty else { return [] }
        guard let cachedInterval else { return nil }

        let interval = expandedInterval(for: dates)

        if cachedInterval.start <= interval.start,
           cachedInterval.end >= interval.end,
           let lastFetch,
           Date().timeIntervalSince(lastFetch) < 1800 {
            return cachedEvents
        }

        return nil
    }

    func prefetchEvents(covering dates: [Date]) async -> Bool {
        guard !dates.isEmpty else { return false }
        guard EKEventStore.authorizationStatus(for: .event) == .fullAccess else { return false }

        let interval = expandedInterval(for: dates)

        if cachedEvents(covering: dates) != nil {
            return false
        }

        if isFetching {
            return false
        }

        isFetching = true
        defer { isFetching = false }

        let predicate = eventStore.predicateForEvents(withStart: interval.start, end: interval.end, calendars: nil)
        let events = eventStore.events(matching: predicate).map(MeetingEvent.init)
        cachedEvents = events
        cachedInterval = DateInterval(start: interval.start, end: interval.end)
        lastFetch = Date()
        return true
    }

    private func expandedInterval(for dates: [Date]) -> DateInterval {
        let sorted = dates.sorted()
        let calendar = Calendar.current
        let start = calendar.date(byAdding: .hour, value: -6, to: sorted.first ?? Date()) ?? Date()
        let end = calendar.date(byAdding: .hour, value: 12, to: sorted.last ?? Date()) ?? Date().addingTimeInterval(12 * 3600)
        return DateInterval(start: start, end: max(start.addingTimeInterval(600), end))
    }
}

private extension NotificationScheduler {
    static func relevantMeetingDates(prayers: [ScheduledPrayer], includeReminders: Bool) -> [Date] {
        var dates = prayers.map { $0.time }
        if includeReminders {
            dates.append(contentsOf: prayers.map { $0.time.addingTimeInterval(-300) })
        }
        return dates
    }
}
