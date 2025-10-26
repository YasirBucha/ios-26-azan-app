import SwiftUI

@main
struct MyAzanApp: App {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var prayerTimeService = PrayerTimeService()
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var settingsManager = SettingsManager()
    @State private var showSplashScreen = true
    @Namespace private var logoTransition
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplashScreen {
                    SplashScreenView(namespace: logoTransition) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showSplashScreen = false
                        }
                    }
                } else {
                    HomeView(namespace: logoTransition)
                        .environmentObject(locationManager)
                        .environmentObject(prayerTimeService)
                        .environmentObject(notificationManager)
                        .environmentObject(settingsManager)
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
                        }
                }
            }
        }
    }
}
