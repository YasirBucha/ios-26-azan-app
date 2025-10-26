import SwiftUI

struct HomeView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var prayerTimeService: PrayerTimeService
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var settingsManager: SettingsManager
    @StateObject private var audioManager = AudioManager()
    @Environment(\.colorScheme) var colorScheme
    @State private var breathingOpacity: Double = 0.7
    @State private var prayerCardScale: Double = 1.0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Deep teal gradient background
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.29, blue: 0.36), // #0d4a5d
                        Color(red: 0.04, green: 0.23, blue: 0.29)  // #0a3a4a
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Subtle radial glow behind main prayer card
                if let nextPrayer = prayerTimeService.nextPrayer {
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 200
                    )
                    .opacity(breathingOpacity)
                    .animation(
                        .easeInOut(duration: 4.0).repeatForever(autoreverses: true),
                        value: breathingOpacity
                    )
                    .onAppear {
                        breathingOpacity = 1.0
                    }
                }
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header Section
                        VStack(spacing: 12) {
                            Text("My Azan")
                                .font(.system(size: 28, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                            
                            VStack(spacing: 4) {
                                Text(locationManager.cityName)
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .foregroundColor(Color(red: 0.75, green: 0.83, blue: 0.85).opacity(0.7)) // #BFD3D8
                                
                                Text(Date().formatted(date: .abbreviated, time: .omitted))
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundColor(Color(red: 0.75, green: 0.83, blue: 0.85).opacity(0.7))
                            }
                        }
                        .padding(.top, 20)
                        
                        // Next Prayer Card
                        if let nextPrayer = prayerTimeService.nextPrayer {
                            PrayerCard(prayer: nextPrayer)
                                .scaleEffect(prayerCardScale)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        prayerCardScale = 0.97
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            prayerCardScale = 1.0
                                        }
                                    }
                                }
                        }
                        
                        // Prayer Times List
                        if prayerTimeService.isLoading {
                            VStack(spacing: 16) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.2)
                                
                                Text("Calculating prayer times...")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.top, 60)
                        } else {
                            LazyVStack(spacing: 16) {
                                ForEach(prayerTimeService.prayerTimes) { prayer in
                                    PrayerCard(prayer: prayer)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        // Test Audio Button
                        if settingsManager.settings.azanEnabled {
                            LiquidGlassBackground {
                                Button(action: {
                                    if audioManager.isPlaying {
                                        audioManager.stopAzan()
                                    } else {
                                        if settingsManager.settings.useDefaultAudio {
                                            audioManager.playAzan(useDefault: true)
                                        } else if let id = settingsManager.settings.selectedAudioFileId {
                                            audioManager.playAzan(useDefault: false, customFileId: id)
                                        }
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: audioManager.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                                        Text(audioManager.isPlaying ? "Stop Azan" : "Test Azan")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Defer location services initialization
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    initializeLocationServices()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
        }
        .onAppear {
            if !prayerTimeService.prayerTimes.isEmpty {
                notificationManager.schedulePrayerNotifications(for: prayerTimeService.prayerTimes, settings: settingsManager.settings)
            }
        }
        .onReceive(prayerTimeService.$prayerTimes) { prayers in
            if !prayers.isEmpty {
                notificationManager.schedulePrayerNotifications(for: prayers, settings: settingsManager.settings)
            }
        }
    }
    
    private func initializeLocationServices() {
        // Request location permission when view appears
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestLocationPermission()
        } else if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
            locationManager.startLocationUpdates()
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

// MARK: - Circular Prayer Card Component
struct CircularPrayerCard: View {
    let prayer: PrayerTime
    let breathingOpacity: Double
    @State private var cardScale: Double = 1.0
    
    var body: some View {
        ZStack {
            // Frosted glass background with soft glow
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 280, height: 280)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 3)
                .shadow(color: Color(red: 0.3, green: 0.72, blue: 1.0).opacity(0.3), radius: 20, x: 0, y: 10)
            
            VStack(spacing: 16) {
                // Next Prayer caption
                Text("Next Prayer")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0.78, green: 0.89, blue: 0.91).opacity(0.7)) // #C7E3E8
                
                // Arabic prayer name
                Text(prayer.arabicName)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                
                // English prayer name
                Text(prayer.name)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
                
                // Time with glow effect
                Text(prayer.timeString)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.3, green: 0.72, blue: 1.0)) // #4DB8FF
                    .shadow(color: Color(red: 0.3, green: 0.72, blue: 1.0).opacity(0.5), radius: 8, x: 0, y: 0)
                
                // Countdown
                if prayer.isUpcoming {
                    Text("in \(formatTimeRemaining(prayer.timeRemaining))")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .scaleEffect(cardScale)
        .animation(.easeInOut(duration: 0.2), value: cardScale)
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

// MARK: - Prayer Row Card Component
struct PrayerRowCard: View {
    let prayer: PrayerTime
    @State private var cardScale: Double = 1.0
    
    var body: some View {
        HStack(spacing: 20) {
            // Arabic prayer name
            Text(prayer.arabicName)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 60, alignment: .leading)
            
            // English prayer name
            Text(prayer.name)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Time
            Text(prayer.timeString)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 3)
        .scaleEffect(cardScale)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                cardScale = 0.97
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    cardScale = 1.0
                }
            }
        }
    }
}

// MARK: - Glass Audio Button Component
struct GlassAudioButton: View {
    @ObservedObject var audioManager: AudioManager
    @ObservedObject var settingsManager: SettingsManager
    @State private var buttonScale: Double = 1.0
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                buttonScale = 0.97
            }
            
            if audioManager.isPlaying {
                audioManager.stopAzan()
            } else {
                if settingsManager.settings.useDefaultAudio {
                    audioManager.playAzan(useDefault: true)
                } else if let id = settingsManager.settings.selectedAudioFileId {
                    audioManager.playAzan(useDefault: false, customFileId: id)
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    buttonScale = 1.0
                }
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: audioManager.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                    .font(.system(size: 20, weight: .medium))
                
                Text(audioManager.isPlaying ? "Stop Azan" : "Test Azan")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.white.opacity(0.9))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 3)
        }
        .scaleEffect(buttonScale)
        .animation(.easeInOut(duration: 0.2), value: buttonScale)
    }
}
