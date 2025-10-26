import Foundation
import ActivityKit
import SwiftUI

// PrayerActivityAttributes struct (copied from MyAzanLiveActivity target for main app use)
struct PrayerActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var nextPrayerName: String
        var nextPrayerArabicName: String
        var nextPrayerTime: Date
        var timeRemaining: TimeInterval
        var cityName: String
    }
    
    var initialPrayerName: String
    var initialPrayerArabicName: String
    var initialPrayerTime: Date
    var cityName: String
}

class LiveActivityManager: ObservableObject {
    @Published var currentActivity: Activity<PrayerActivityAttributes>?
    
    init() {
        // Initialize if needed
    }
    
    func startPrayerActivity(prayer: PrayerTime) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        let attributes = PrayerActivityAttributes(
            initialPrayerName: prayer.name,
            initialPrayerArabicName: prayer.arabicName,
            initialPrayerTime: prayer.time,
            cityName: "Unknown"
        )
        
        let initialState = PrayerActivityAttributes.ContentState(
            nextPrayerName: prayer.name,
            nextPrayerArabicName: prayer.arabicName,
            nextPrayerTime: prayer.time,
            timeRemaining: prayer.time.timeIntervalSinceNow,
            cityName: "Unknown"
        )
        
        do {
            let activity = try Activity<PrayerActivityAttributes>.request(
                attributes: attributes,
                contentState: initialState,
                pushType: nil
            )
            currentActivity = activity
        } catch {
            print("Error starting activity: \(error)")
        }
    }
    
    func updatePrayerActivity(prayer: PrayerTime) {
        guard let activity = currentActivity else { return }
        
        let state = PrayerActivityAttributes.ContentState(
            nextPrayerName: prayer.name,
            nextPrayerArabicName: prayer.arabicName,
            nextPrayerTime: prayer.time,
            timeRemaining: prayer.time.timeIntervalSinceNow,
            cityName: "Unknown"
        )
        
        Task {
            await activity.update(using: state)
        }
    }
    
    func stopActivity() {
        guard let activity = currentActivity else { return }
        
        Task {
            await activity.end(dismissalPolicy: .immediate)
            currentActivity = nil
        }
    }
}
