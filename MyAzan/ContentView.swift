import SwiftUI

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

#Preview {
    ContentView()
        .environmentObject(LocationManager())
        .environmentObject(PrayerTimeService())
        .environmentObject(NotificationManager())
        .environmentObject(SettingsManager())
        .environmentObject(AudioManager())
        .environmentObject(LiveActivityManager())
}
