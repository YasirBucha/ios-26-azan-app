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
    @State private var contentScale: Double = 0.95
    @State private var contentOpacity: Double = 0.0
    @State private var contentBlur: Double = 10.0
    @State private var gearIconScale: Double = 1.0
    @State private var rippleOpacity: Double = 0.0
    @State private var rippleRadius: Double = 20.0
    @State private var shimmerOffset: Double = -200.0
    @State private var offButtonScale: Double = 1.0
    @State private var vibrateButtonScale: Double = 1.0
    @State private var soundButtonScale: Double = 1.0
    @Namespace private var liquidBackground
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Deep teal gradient background with matched geometry
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(red: 0.05, green: 0.29, blue: 0.36), // #0d4a5d
                            Color(red: 0.04, green: 0.23, blue: 0.29)  // #0a3a4a
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .matchedGeometryEffect(id: "liquidBackground", in: liquidBackground)
                    .ignoresSafeArea()
                    
                    // Soft light flare at top center
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.08),
                            Color.clear
                        ],
                        center: .top,
                        startRadius: 0,
                        endRadius: 300
                    )
                    .ignoresSafeArea()
                }
                
                // Subtle radial glow behind main prayer card
                if prayerTimeService.nextPrayer != nil {
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
                
                VStack(spacing: 32) {
                    
                    
                    // Custom Row Section
                    VStack(spacing: 8) {
                        HStack(alignment: .top, spacing: 16) {
                            // Left: Circular image
                            Image("CircularImage")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .clipped()
                                .clipShape(Circle())
                            
                            // Middle: Rectangle image + location/date below
                            VStack(alignment: .leading, spacing: 8) {
                                Image("RectangleImage")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 140, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .padding(.top, 20)
                                    .padding(.leading, -14)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(locationManager.cityName)
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.white.opacity(0.9))
                                    
                                    Text(Date().formatted(date: .abbreviated, time: .omitted))
                                        .font(.system(size: 12, weight: .regular, design: .rounded))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                .padding(.top, -16)
                            }
                            
                            // Right: Settings button
                            NavigationLink(destination: SettingsView().environmentObject(settingsManager)) {
                                LiquidGlassIconButton(systemName: "gearshape.fill")
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 20)
                    
                    // Rectangular Next Prayer Card
                    if let nextPrayer = prayerTimeService.nextPrayer {
                        HStack(spacing: 20) {
                            // Left side - Prayer info
                            VStack(alignment: .leading, spacing: 8) {
                                // Next Prayer caption
                                Text("Next Prayer")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(red: 0.78, green: 0.89, blue: 0.91).opacity(0.7)) // #C7E3E8
                                
                                // English prayer name with icon
                                HStack(alignment: .center, spacing: 8) {
                                    Image(systemName: iconForPrayer(nextPrayer.name))
                                        .font(.system(size: 28, weight: .medium))
                                        .foregroundColor(Color(red: 0.78, green: 0.89, blue: 0.91).opacity(0.7))
                                    
                                    Text(nextPrayer.name)
                                        .font(.system(size: 32, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white.opacity(0.85))
                                        .minimumScaleFactor(0.7)
                                        .lineLimit(1)
                                }
                            }
                            
                            Spacer()
                            
                            // Right side - Time
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(nextPrayer.timeString)
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(red: 0.3, green: 0.72, blue: 1.0)) // #4DB8FF
                                    .shadow(color: Color(red: 0.3, green: 0.72, blue: 1.0).opacity(0.5), radius: 8, x: 0, y: 0)
                                
                                // Countdown
                                if nextPrayer.isUpcoming {
                                    Text("in \(formatTimeRemaining(nextPrayer.timeRemaining))")
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.black.opacity(0.35))
                        )
                        .glassedEffect(in: RoundedRectangle(cornerRadius: 20), interactive: false)
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
                        .padding(.horizontal, 20)
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
                        VStack(spacing: 16) {
                            // Master notification controls
                            HStack(spacing: 20) {
                                Text("Prayer Notifications")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Spacer()
                                
                                // Master control buttons
                                HStack(spacing: 12) {
                                    let masterState = getMasterNotificationState()
                                    Button(action: {
                                        // Haptic feedback
                                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                        impactFeedback.impactOccurred()
                                        
                                        // Visual feedback
                                        withAnimation(.easeInOut(duration: 0.1)) {
                                            offButtonScale = 0.8
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            withAnimation(.easeInOut(duration: 0.1)) {
                                                offButtonScale = 1.0
                                            }
                                        }
                                        
                                        print("🔔 Master OFF button tapped")
                                        settingsManager.settings.setAllPrayerNotifications(to: .off)
                                    }) {
                                        Image(systemName: "bell.slash")
                                            .font(.system(size: 18, weight: .medium))
                                            .foregroundColor(.gray.opacity(0.5))
                                            .overlay(
                                                masterState == .off ? 
                                                Circle()
                                                    .stroke(.gray.opacity(0.8), lineWidth: 2)
                                                    .frame(width: 32, height: 32) : nil
                                            )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .scaleEffect(offButtonScale)
                                    
                                    Button(action: {
                                        // Haptic feedback
                                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                        impactFeedback.impactOccurred()
                                        
                                        // Visual feedback
                                        withAnimation(.easeInOut(duration: 0.1)) {
                                            vibrateButtonScale = 0.8
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            withAnimation(.easeInOut(duration: 0.1)) {
                                                vibrateButtonScale = 1.0
                                            }
                                        }
                                        
                                        print("🔔 Master VIBRATE button tapped")
                                        settingsManager.settings.setAllPrayerNotifications(to: .vibrate)
                                    }) {
                                        Image(systemName: "bell.badge")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(.orange.opacity(0.5))
                                            .shadow(color: .orange.opacity(0.4), radius: 6, x: 0, y: 0)
                                            .overlay(
                                                masterState == .vibrate ? 
                                                Circle()
                                                    .stroke(.orange.opacity(0.8), lineWidth: 2)
                                                    .frame(width: 32, height: 32) : nil
                                            )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .scaleEffect(vibrateButtonScale)
                                    
                                    Button(action: {
                                        // Haptic feedback
                                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                        impactFeedback.impactOccurred()
                                        
                                        // Visual feedback
                                        withAnimation(.easeInOut(duration: 0.1)) {
                                            soundButtonScale = 0.8
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            withAnimation(.easeInOut(duration: 0.1)) {
                                                soundButtonScale = 1.0
                                            }
                                        }
                                        
                                        print("🔔 Master SOUND button tapped")
                                        settingsManager.settings.setAllPrayerNotifications(to: .sound)
                                    }) {
                                        Image(systemName: "bell.fill")
                                            .font(.system(size: 18, weight: .medium))
                                            .foregroundColor(.blue.opacity(0.5))
                                            .overlay(
                                                masterState == .sound ? 
                                                Circle()
                                                    .stroke(.blue.opacity(0.8), lineWidth: 2)
                                                    .frame(width: 32, height: 32) : nil
                                            )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .scaleEffect(soundButtonScale)
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.black.opacity(0.5))
                            )
                            .glassedEffect(in: RoundedRectangle(cornerRadius: 16), interactive: false)
                            
                            // Prayer cards list
                            ScrollView {
                                LazyVStack(spacing: 16) {
                                    ForEach(prayerTimeService.prayerTimes) { prayer in
                                        PrayerCard(prayer: prayer)
                                    }
                                }
                                .padding(.horizontal, 8)
                            }
                            .frame(maxHeight: 400)
                        }
                        .padding(.horizontal, 24)
                    }
                }
                .safeAreaInset(edge: .top) {
                    Color.clear.frame(height: 0)
                }
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 0)
                }
                .scaleEffect(contentScale)
                .opacity(contentOpacity)
                .blur(radius: contentBlur)
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Start home screen entrance animation
                startHomeEntranceAnimation()
                
                // Defer location services initialization
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    locationManager.refreshLocationIfNeeded(force: false)
                }
            }
        }
        .onReceive(prayerTimeService.$prayerTimes) { prayers in
            if !prayers.isEmpty {
                notificationManager.schedulePrayerNotifications(for: prayers, settings: settingsManager.settings)
            }
        }
    }
    
    private func startHomeEntranceAnimation() {
        // Home screen content fades in with scale and blur fade out (0.8s, ease out)
        withAnimation(.easeOut(duration: 0.8)) {
            contentScale = 1.0
            contentOpacity = 1.0
            contentBlur = 0.0
        }
        
        // Shimmer effect on title
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeInOut(duration: 0.8)) {
                shimmerOffset = 200
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                shimmerOffset = -200
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
    
    private func getMasterNotificationState() -> PrayerNotificationState? {
        let prayerStates = prayerTimeService.prayerTimes.map { prayer in
            settingsManager.settings.getPrayerNotificationState(for: prayer.name)
        }
        
        // If all prayers have the same state, return that state
        if let firstState = prayerStates.first, prayerStates.allSatisfy({ $0 == firstState }) {
            return firstState
        }
        
        // If prayers have mixed states, return nil (no master state)
        return nil
    }
    
    private func iconForPrayer(_ prayerName: String) -> String {
        switch prayerName.lowercased() {
        case "fajr":
            return "sunrise"
        case "dhuhr", "zuhr":
            return "sun.max"
        case "asr":
            return "sun.horizon"
        case "maghrib":
            return "sunset"
        case "isha":
            return "moon"
        default:
            return "clock"
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
                                    Color.white.opacity(0.4),
                                    Color.white.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: .white.opacity(0.2), radius: 8, x: 0, y: 4)
                .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
            
            VStack(spacing: 16) {
                // Next Prayer caption
                Text("Next Prayer")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0.78, green: 0.89, blue: 0.91).opacity(0.7)) // #C7E3E8
                
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
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
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
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.4),
                            Color.white.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: .white.opacity(0.2), radius: 8, x: 0, y: 4)
        .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
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
                    audioManager.playAzan(useDefault: true, volume: settingsManager.settings.appVolume)
                } else if let id = settingsManager.settings.selectedAudioFileId {
                    audioManager.playAzan(useDefault: false, customFileId: id, volume: settingsManager.settings.appVolume)
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
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: .white.opacity(0.2), radius: 8, x: 0, y: 4)
            .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
        }
        .scaleEffect(buttonScale)
        .animation(.easeInOut(duration: 0.2), value: buttonScale)
    }
}

#Preview {
    HomeView()
        .environmentObject(LocationManager())
        .environmentObject(PrayerTimeService())
        .environmentObject(NotificationManager())
        .environmentObject(SettingsManager())
}
