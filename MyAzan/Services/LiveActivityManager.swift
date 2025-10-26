import Foundation
import ActivityKit
import Combine

class LiveActivityManager: ObservableObject {
    @Published var currentActivity: Activity<PrayerActivityAttributes>?
    
    func startLiveActivity(for prayer: PrayerTime, cityName: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not enabled")
            return
        }
        
        // End current activity if exists
        endCurrentActivity()
        
        let attributes = PrayerActivityAttributes(
            initialPrayerName: prayer.name,
            initialPrayerArabicName: prayer.arabicName,
            initialPrayerTime: prayer.time,
            cityName: cityName
        )
        
        let initialState = PrayerActivityAttributes.ContentState(
            nextPrayerName: prayer.name,
            nextPrayerArabicName: prayer.arabicName,
            nextPrayerTime: prayer.time,
            timeRemaining: prayer.timeRemaining,
            cityName: cityName
        )
        
        do {
            let activity = try Activity<PrayerActivityAttributes>.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
            
            currentActivity = activity
            print("Live Activity started for \(prayer.name)")
            
            // Schedule updates
            scheduleLiveActivityUpdates(for: prayer)
            
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }
    
    func updateLiveActivity(for prayer: PrayerTime) {
        guard let activity = currentActivity else { return }
        
        let updatedState = PrayerActivityAttributes.ContentState(
            nextPrayerName: prayer.name,
            nextPrayerArabicName: prayer.arabicName,
            nextPrayerTime: prayer.time,
            timeRemaining: prayer.timeRemaining,
            cityName: activity.attributes.cityName
        )
        
        Task {
            await activity.update(using: updatedState)
        }
    }
    
    func endCurrentActivity() {
        guard let activity = currentActivity else { return }
        
        Task {
            await activity.end(dismissalPolicy: .immediate)
        }
        
        currentActivity = nil
    }
    
    private func scheduleLiveActivityUpdates(for prayer: PrayerTime) {
        let timeRemaining = prayer.timeRemaining
        
        // Smart update frequency based on time remaining
        let updateInterval: TimeInterval
        if timeRemaining < 600 { // Less than 10 minutes
            updateInterval = 60 // Every minute
        } else if timeRemaining < 3600 { // Less than 1 hour
            updateInterval = 300 // Every 5 minutes
        } else {
            updateInterval = 900 // Every 15 minutes
        }
        
        // Schedule next update
        DispatchQueue.main.asyncAfter(deadline: .now() + updateInterval) { [weak self] in
            self?.updateLiveActivity(for: prayer)
        }
    }
}
