import SwiftUI

@main
struct MyAzanApp: App {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var prayerTimeService = PrayerTimeService()
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var settingsManager = SettingsManager()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(locationManager)
                .environmentObject(prayerTimeService)
                .environmentObject(notificationManager)
                .environmentObject(settingsManager)
        }
    }
}
