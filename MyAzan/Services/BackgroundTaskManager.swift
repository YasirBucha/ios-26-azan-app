import Foundation
import BackgroundTasks
import UserNotifications

@MainActor
class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()
    private static var didRegister = false
    
    private init() {}
    
    func registerBackgroundTasks() {
        guard !Self.didRegister else { return }
        Self.didRegister = true
        // Register background app refresh task
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.myazan.refresh", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        
        // Register background processing task
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.myazan.processing", using: nil) { task in
            self.handleBackgroundProcessing(task: task as! BGProcessingTask)
        }
    }
    
    func scheduleBackgroundTasks() {
        scheduleAppRefresh()
        scheduleBackgroundProcessing()
    }
    
    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.myazan.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes from now
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background app refresh scheduled")
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    private func scheduleBackgroundProcessing() {
        let request = BGProcessingTaskRequest(identifier: "com.myazan.processing")
        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = false
        request.earliestBeginDate = Date(timeIntervalSinceNow: 24 * 60 * 60) // 24 hours from now
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background processing scheduled")
        } catch {
            print("Could not schedule background processing: \(error)")
        }
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        print("Handling background app refresh")
        
        // Schedule next refresh
        scheduleAppRefresh()
        
        // Update prayer times
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        // Perform prayer time update
        updatePrayerTimesInBackground { success in
            task.setTaskCompleted(success: success)
        }
    }
    
    private func handleBackgroundProcessing(task: BGProcessingTask) {
        print("Handling background processing")
        
        // Schedule next processing
        scheduleBackgroundProcessing()
        
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        // Perform daily prayer time calculation and notification scheduling
        performDailyUpdate { success in
            task.setTaskCompleted(success: success)
        }
    }
    
    private func updatePrayerTimesInBackground(completion: @escaping (Bool) -> Void) {
        // This would typically involve:
        // 1. Getting current location (if available)
        // 2. Recalculating prayer times
        // 3. Updating shared UserDefaults for widgets
        // 4. Rescheduling notifications
        
        DispatchQueue.global(qos: .background).async {
            // Simulate prayer time update
            let success = true // Replace with actual implementation
            
            // After any updates, attempt to reassert Live Activity using cached data
            self.reassertLiveActivityFromCache()
            
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
    
    private func performDailyUpdate(completion: @escaping (Bool) -> Void) {
        // This would typically involve:
        // 1. Recalculating all prayer times for the day
        // 2. Updating shared UserDefaults
        // 3. Rescheduling all notifications
        // 4. Updating Live Activities if active
        
        DispatchQueue.global(qos: .background).async {
            // Simulate daily update
            let success = true // Replace with actual implementation
            
            // After any updates, attempt to reassert Live Activity using cached data
            self.reassertLiveActivityFromCache()
            
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
    
    private func reassertLiveActivityFromCache() {
        // Only proceed if user has Live Activities enabled
        let liveEnabled = SharedDefaults.bool(forKey: "liveActivityEnabled", default: true)
        guard liveEnabled else { return }
        let azanEnabled = SharedDefaults.bool(forKey: "azanEnabled", default: true)
        
        // Load cached prayers written by PrayerTimeService
        let decoder = JSONDecoder()
        var cachedPrayers: [PrayerTime] = []
        var cachedNext: PrayerTime? = nil
        
        if let data = SharedDefaults.data(forKey: "cachedPrayerTimes"),
           let prayers = try? decoder.decode([PrayerTime].self, from: data) {
            cachedPrayers = prayers
        }
        if let nextData = SharedDefaults.data(forKey: "cachedNextPrayer"),
           let next = try? decoder.decode(PrayerTime.self, from: nextData) {
            cachedNext = next
        }
        
        // Update or start the activity on the main actor
        Task { @MainActor in
            LiveActivityManager.shared.ensureActive(prayers: cachedPrayers, nextPrayer: cachedNext, cityName: "", isAzanEnabled: azanEnabled)
        }
    }
}
