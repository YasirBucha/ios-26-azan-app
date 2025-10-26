import SwiftUI

@main
struct MyAzanApp: App {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var prayerTimeService = PrayerTimeService()
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var settingsManager = SettingsManager()
    @StateObject private var audioManager = AudioManager()
    @StateObject private var liveActivityManager = LiveActivityManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
                .environmentObject(prayerTimeService)
                .environmentObject(notificationManager)
                .environmentObject(settingsManager)
                .environmentObject(audioManager)
                .environmentObject(liveActivityManager)
                .onAppear {
                    setupApp()
                }
        }
    }
    
    private func setupApp() {
        // Register background tasks
        BackgroundTaskManager.shared.registerBackgroundTasks()
        BackgroundTaskManager.shared.scheduleBackgroundTasks()
        
        // Request permissions on app launch
        locationManager.requestLocationPermission()
        notificationManager.requestNotificationPermission()
        
        // Start location updates
        locationManager.startLocationUpdates()
    }
}

struct ContentView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var prayerTimeService: PrayerTimeService
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var liveActivityManager: LiveActivityManager
    
    var body: some View {
        NavigationStack {
            HomeView()
                .onReceive(locationManager.$currentLocation) { location in
                    if let location = location {
                        prayerTimeService.updateLocation(latitude: location.coordinate.latitude, 
                                                      longitude: location.coordinate.longitude)
                    }
                }
                .onReceive(prayerTimeService.$nextPrayer) { nextPrayer in
                    if let nextPrayer = nextPrayer, settingsManager.settings.liveActivityEnabled {
                        liveActivityManager.startLiveActivity(for: nextPrayer, cityName: locationManager.cityName)
                    }
                }
        }
    }
}
