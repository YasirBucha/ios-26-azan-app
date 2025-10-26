import SwiftUI

struct HomeView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var prayerTimeService: PrayerTimeService
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var settingsManager: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: colorScheme == .dark ? 
                        [Color.black, Color.blue.opacity(0.1)] :
                        [Color.white, Color.blue.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 8) {
                            Text("My Azan")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text(locationManager.cityName)
                                .font(.title3)
                                .foregroundColor(.secondary)
                            
                            Text(Date().formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top)
                        
                        // Next Prayer Highlight
                        if let nextPrayer = prayerTimeService.nextPrayer {
                            LiquidGlassBackground {
                                VStack(spacing: 12) {
                                    Text("Next Prayer")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    
                                    Text(nextPrayer.arabicName)
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    
                                    Text(nextPrayer.name)
                                        .font(.title2)
                                        .foregroundColor(.secondary)
                                    
                                    Text(nextPrayer.timeString)
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                    
                                    if nextPrayer.isUpcoming {
                                        Text("in \(formatTimeRemaining(nextPrayer.timeRemaining))")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding()
                            }
                            .background(Material.regular, in: RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                            )
                            .shadow(color: Color.blue.opacity(0.2), radius: 20, x: 0, y: 10)
                        }
                        
                        // Prayer Times List
                        if prayerTimeService.isLoading {
                            ProgressView("Calculating prayer times...")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(prayerTimeService.prayerTimes) { prayer in
                                    PrayerCard(prayer: prayer)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Request location permission when view appears
                if locationManager.authorizationStatus == .notDetermined {
                    locationManager.requestLocationPermission()
                } else if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
                    locationManager.startLocationUpdates()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .onAppear {
            if !prayerTimeService.prayerTimes.isEmpty {
                notificationManager.schedulePrayerNotifications(for: prayerTimeService.prayerTimes)
            }
        }
        .onReceive(prayerTimeService.$prayerTimes) { prayers in
            if !prayers.isEmpty {
                notificationManager.schedulePrayerNotifications(for: prayers)
            }
        }
    }
    
    private func formatTimeRemaining(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
