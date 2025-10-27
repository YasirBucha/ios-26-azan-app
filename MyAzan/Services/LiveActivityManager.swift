import Foundation
import ActivityKit
import SwiftUI
import UIKit

// PrayerActivityAttributes struct (copied from MyAzanLiveActivity target for main app use)
struct PrayerActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var nextPrayerName: String
        var nextPrayerArabicName: String
        var nextPrayerTime: Date
        var timeRemaining: TimeInterval
        var cityName: String
        var progressPercentage: Double
        var isAzanEnabled: Bool
        var currentDate: Date
    }
    
    var initialPrayerName: String
    var initialPrayerArabicName: String
    var initialPrayerTime: Date
    var cityName: String
    var nextPrayerName: String
    var nextPrayerTime: Date
    var isAzanEnabled: Bool
}

@MainActor
class LiveActivityManager: ObservableObject {
    @Published var currentActivity: Activity<PrayerActivityAttributes>?
    
    init() {
        // Initialize if needed
    }
    
    func startPrayerActivity(prayer: PrayerTime, nextPrayer: PrayerTime, cityName: String, isAzanEnabled: Bool) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        let attributes = PrayerActivityAttributes(
            initialPrayerName: prayer.name,
            initialPrayerArabicName: prayer.arabicName,
            initialPrayerTime: prayer.time,
            cityName: cityName,
            nextPrayerName: nextPrayer.name,
            nextPrayerTime: nextPrayer.time,
            isAzanEnabled: isAzanEnabled
        )
        
        let timeRemaining = prayer.time.timeIntervalSinceNow
        let progressPercentage = calculateProgressPercentage(currentTime: Date(), prayerTime: prayer.time, nextPrayerTime: nextPrayer.time)
        
        let initialState = PrayerActivityAttributes.ContentState(
            nextPrayerName: prayer.name,
            nextPrayerArabicName: prayer.arabicName,
            nextPrayerTime: prayer.time,
            timeRemaining: timeRemaining,
            cityName: cityName,
            progressPercentage: progressPercentage,
            isAzanEnabled: isAzanEnabled,
            currentDate: Date()
        )
        let content = ActivityContent(state: initialState, staleDate: nil)
        
        do {
            let activity = try Activity<PrayerActivityAttributes>.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            currentActivity = activity
            
            // Schedule updates every minute
            schedulePeriodicUpdates()
        } catch {
            print("Error starting activity: \(error)")
        }
    }
    
    func updatePrayerActivity(prayer: PrayerTime, nextPrayer: PrayerTime, cityName: String, isAzanEnabled: Bool) {
        guard let activity = currentActivity else { return }
        
        let timeRemaining = prayer.time.timeIntervalSinceNow
        let progressPercentage = calculateProgressPercentage(currentTime: Date(), prayerTime: prayer.time, nextPrayerTime: nextPrayer.time)
        
        let state = PrayerActivityAttributes.ContentState(
            nextPrayerName: prayer.name,
            nextPrayerArabicName: prayer.arabicName,
            nextPrayerTime: prayer.time,
            timeRemaining: timeRemaining,
            cityName: cityName,
            progressPercentage: progressPercentage,
            isAzanEnabled: isAzanEnabled,
            currentDate: Date()
        )
        let content = ActivityContent(state: state, staleDate: nil)
        
        Task {
            await activity.update(content)
            
            // Trigger haptic feedback if countdown reaches 0
            if timeRemaining <= 0 && isAzanEnabled {
                await MainActor.run {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }
            }
        }
    }
    
    func stopActivity() {
        guard let activity = currentActivity else { return }
        
        Task {
            let currentState = activity.contentState
            let content = ActivityContent(state: currentState, staleDate: nil)
            await activity.end(content, dismissalPolicy: .immediate)
            await MainActor.run {
                self.currentActivity = nil
            }
        }
    }
    
    private func schedulePeriodicUpdates() {
        Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            // This will be handled by the main app's prayer time service
            // The timer here is just a fallback
        }
    }
    
    private func calculateProgressPercentage(currentTime: Date, prayerTime: Date, nextPrayerTime: Date) -> Double {
        let totalDuration = nextPrayerTime.timeIntervalSince(prayerTime)
        let elapsed = currentTime.timeIntervalSince(prayerTime)
        
        guard totalDuration > 0 else { return 0.0 }
        
        let percentage = elapsed / totalDuration
        return max(0.0, min(1.0, percentage))
    }
}
