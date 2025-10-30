import SwiftUI

@main
struct MyAzanApp: App {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var prayerTimeService = PrayerTimeService()
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var settingsManager = SettingsManager()
    @Namespace private var namespace
    @State private var showSplash = true
    @StateObject private var liveActivityManager = LiveActivityManager()

    init() {
        PerformanceLogger.resetBaseline("MyAzanApp init")
        PerformanceLogger.event("MyAzanApp initialised")
    }
    
    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashScreenView(namespace: namespace) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showSplash = false
                        PerformanceLogger.event("Splash dismissed")
                    }
                }
            } else {
                HomeView()
                    .environmentObject(locationManager)
                    .environmentObject(prayerTimeService)
                    .environmentObject(notificationManager)
                    .environmentObject(settingsManager)
                    .environmentObject(liveActivityManager)
                    .onReceive(locationManager.$currentLocation) { location in
                        if let location = location {
                            prayerTimeService.updateLocation(
                                latitude: location.coordinate.latitude,
                                longitude: location.coordinate.longitude
                            )
                        }
                    }
                    .onAppear {
                        // Request notification permissions on app launch
                        notificationManager.requestNotificationPermissionIfNeeded()
                        
                        // Set managers in PrayerTimeService for notification scheduling
                        prayerTimeService.setManagers(notificationManager: notificationManager, settingsManager: settingsManager)
                        
                        // Apply initial design to Live Activity
                        liveActivityManager.setDesign(settingsManager.settings.liveActivityDesign)
                        
                        // Attempt to start or resume Live Activity if enabled
                        maybeStartOrUpdateLiveActivity()
                        
                        // Register and schedule background tasks
                        BackgroundTaskManager.shared.registerBackgroundTasks()
                        BackgroundTaskManager.shared.scheduleBackgroundTasks()
                    }
                    .onChange(of: settingsManager.settings.liveActivityEnabled) { _ in
                        // Start or stop based on toggle
                        if settingsManager.settings.liveActivityEnabled {
                            maybeStartOrUpdateLiveActivity()
                        } else {
                            liveActivityManager.stopActivity()
                        }
                    }
                    .onChange(of: settingsManager.settings.liveActivityDesign) { newDesign in
                        liveActivityManager.setDesign(newDesign)
                        // If an activity is active, design change will be picked up by restart logic
                        maybeStartOrUpdateLiveActivity()
                    }
                    .onChange(of: prayerTimeService.nextPrayer?.id) { _ in
                        // Keep activity updated across prayer transitions
                        maybeStartOrUpdateLiveActivity()
                    }
                    .onChange(of: scenePhase) { newPhase in
                        if newPhase == .active {
                            // Refresh activity when app enters foreground
                            maybeStartOrUpdateLiveActivity()
                        } else if newPhase == .background {
                            // Reschedule background tasks when going to background
                            BackgroundTaskManager.shared.scheduleBackgroundTasks()
                        }
                    }
            }
        }
    }
    
    @Environment(\.scenePhase) private var scenePhase
    
    private func maybeStartOrUpdateLiveActivity() {
        guard settingsManager.settings.liveActivityEnabled else { return }
        
        // Determine current and next prayers from service
        let prayers = prayerTimeService.prayerTimes.sorted { $0.time < $1.time }
        guard let next = prayerTimeService.nextPrayer ?? prayers.first(where: { $0.isUpcoming }) else { return }
        
        // Find current prayer as the latest before next
        let current = prayers.last(where: { $0.time <= Date() }) ?? next
        
        // City placeholder: derive from LocationManager if available later
        let cityName = ""
        
        if liveActivityManager.currentActivity != nil {
            liveActivityManager.updatePrayerActivity(prayer: current, nextPrayer: next, cityName: cityName, isAzanEnabled: settingsManager.settings.azanEnabled)
        } else {
            liveActivityManager.startPrayerActivity(prayer: current, nextPrayer: next, cityName: cityName, isAzanEnabled: settingsManager.settings.azanEnabled)
        }
    }
}
