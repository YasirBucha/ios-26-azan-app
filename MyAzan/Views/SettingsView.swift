import SwiftUI
import EventKit
import ActivityKit
import UIKit

struct SettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var notificationManager: NotificationManager
    @StateObject private var audioFileManager = AudioFileManager.shared
    @StateObject private var audioManager = AudioManager()
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @State private var showingAudioManagement = false
    @State private var selectedTheme: ThemeMode = .system
    @State private var selectedAccentColor: AccentColor = .blue
    @State private var cardsScale: [Double] = [0.95, 0.95, 0.95, 0.95]
    @State private var calendarAuthorizationStatus: EKAuthorizationStatus = .notDetermined
    @State private var cardsOpacity: [Double] = [0.0, 0.0, 0.0, 0.0]
    @State private var cardsBlur: [Double] = [0.0, 0.0, 0.0, 0.0]
    @Namespace private var liquidBackground
    
    // Live Activity health check state
    @State private var showLiveActivityAlert = false
    @State private var liveActivitiesEnabledSystemwide = true
    @State private var showLiveActivityHelp = false
    @State private var hasCheckedHealth = false
    
    enum ThemeMode: String, CaseIterable {
        case light = "Light"
        case dark = "Dark"
        case system = "System"
    }
    
    enum AccentColor: String, CaseIterable {
        case blue = "Blue"
        case teal = "Teal"
        case purple = "Purple"
        case green = "Green"
        
        var color: Color {
            switch self {
            case .blue: return Color(red: 0.3, green: 0.72, blue: 1.0) // #4DB8FF
            case .teal: return Color(red: 0.0, green: 0.8, blue: 0.8)
            case .purple: return Color(red: 0.6, green: 0.4, blue: 1.0)
            case .green: return Color(red: 0.2, green: 0.8, blue: 0.4)
            }
        }
    }
    
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
                
                VStack(spacing: 0) {
                    // Header Section with Back Button (Fixed)
                    VStack(spacing: 8) {
                        HStack(spacing: 12) {
                            Button(action: { dismiss() }) {
                                LiquidGlassIconButton(systemName: "chevron.left", interactive: false)
                            }
                            
                            Text("Settings")
                                .font(.system(size: 26, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                                .frame(maxWidth: .infinity)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 40)
                    
                    // Scrollable Content
                    ScrollView {
                        LazyVStack(spacing: 24, pinnedViews: []) {
                        
                        // Audio Settings Card (basic rounded rectangle + glassedEffect)
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Audio Settings")
                                .font(.system(size: 18, weight: .semibold, design: .default))
                                .foregroundColor(.white.opacity(0.9))
                            
                            // Azan Voice Play/Pause Toggle
                            HStack {
                                Text("Azan Voice")
                                    .font(.system(size: 16, weight: .regular, design: .default))
                                    .foregroundColor(.white.opacity(0.85))
                                Spacer()
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        if audioManager.isPlaying {
                                            audioManager.stopAzan()
                                        } else {
                                            if settingsManager.settings.useDefaultAudio {
                                                audioManager.playAzan(useDefault: true, volume: settingsManager.settings.appVolume)
                                            } else if let id = settingsManager.settings.selectedAudioFileId {
                                                audioManager.playAzan(useDefault: false, customFileId: id, volume: settingsManager.settings.appVolume)
                                            }
                                        }
                                    }
                                }) {
                                    Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                        .font(.system(size: 24, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            
                            // Volume Level Row
                            HStack {
                                Text("App Volume Level")
                                    .font(.system(size: 16, weight: .regular, design: .default))
                                    .foregroundColor(.white.opacity(0.85))
                                
                                Spacer()
                                
                                Text("\(Int(settingsManager.settings.appVolume * 100))%")
                                    .font(.system(size: 14, weight: .medium, design: .default))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            // Volume Slider
                            HStack {
                                Image(systemName: "speaker.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.6))
                                
                                Slider(value: Binding(
                                    get: { Double(settingsManager.settings.appVolume) },
                                    set: { newValue in
                                        settingsManager.settings.appVolume = Float(newValue)
                                        // Update volume of currently playing audio
                                        audioManager.updateVolume(Float(newValue))
                                    }
                                ), in: 0...1)
                                    .accentColor(Color(red: 0.3, green: 0.72, blue: 1.0)) // #4DB8FF
                                    .background(
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.white.opacity(0.1))
                                            .frame(height: 6)
                                    )
                                
                                Image(systemName: "speaker.wave.3.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            
                            // Volume Description
                            Text("Controls volume for azan playback. System notifications use device volume.")
                                .font(.system(size: 12, weight: .regular, design: .default))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.clear)
                        )
                        .glassedEffect(in: RoundedRectangle(cornerRadius: 20), interactive: false)
                        
                        // Notifications Card (basic rounded rectangle + glassedEffect)
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Notifications")
                                .font(.system(size: 18, weight: .semibold, design: .default))
                                .foregroundColor(.white.opacity(0.9))
                            
                            // Prayer Time Alerts Toggle
                            HStack {
                                Text("Prayer Time Alerts")
                                    .font(.system(size: 16, weight: .regular, design: .default))
                                    .foregroundColor(.white.opacity(0.85))
                                Spacer()
                                Toggle(isOn: Binding(
                                    get: { settingsManager.settings.azanEnabled },
                                    set: { settingsManager.updateAzanEnabled($0) }
                                )) {
                                    EmptyView()
                                }
                                .labelsHidden()
                                .toggleStyle(.automatic)
                            }
                            
                            // Pre-Azan Reminder Toggle
                            HStack {
                                Text("Pre-Azan Reminder (5 min before)")
                                    .font(.system(size: 16, weight: .regular, design: .default))
                                    .foregroundColor(.white.opacity(0.85))
                                Spacer()
                                Toggle(isOn: Binding(
                                    get: { settingsManager.settings.reminderEnabled },
                                    set: { settingsManager.updateReminderEnabled($0) }
                                )) {
                                    EmptyView()
                                }
                                .labelsHidden()
                                .toggleStyle(.automatic)
                            }
                            
                            
                            // Vibration Only During Meetings Toggle
                            HStack {
                                Text("Vibration Only During Meetings")
                                    .font(.system(size: 16, weight: .regular, design: .default))
                                    .foregroundColor(.white.opacity(0.85))
                                Spacer()
                                Toggle(isOn: Binding(
                                    get: { settingsManager.settings.vibrationOnlyDuringMeetings },
                                    set: { newValue in
                                        if newValue {
                                            requestCalendarPermission()
                                        } else {
                                            settingsManager.updateVibrationOnlyDuringMeetings(false)
                                        }
                                    }
                                )) {
                                    EmptyView()
                                }
                                .labelsHidden()
                                .toggleStyle(.automatic)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.clear)
                        )
                        .glassedEffect(in: RoundedRectangle(cornerRadius: 20), interactive: false)
                        
                        // Live Activities Card (basic rounded rectangle + glassedEffect)
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Live Activities")
                                .font(.system(size: 18, weight: .semibold, design: .default))
                                .foregroundColor(.white.opacity(0.9))
                            
                            // Live Activity Toggle
                            HStack {
                                Text("Live Activity")
                                    .font(.system(size: 16, weight: .regular, design: .default))
                                    .foregroundColor(.white.opacity(0.85))
                                Spacer()
                                Toggle(isOn: Binding(
                                    get: { settingsManager.settings.liveActivityEnabled },
                                    set: { value in
                                        settingsManager.updateLiveActivityEnabled(value)
                                        if value {
                                            checkLiveActivityHealth()
                                            hasCheckedHealth = true
                                        }
                                    }
                                )) {
                                    EmptyView()
                                }
                                .labelsHidden()
                                .toggleStyle(.automatic)
                            }
                            
                            // Live Activity Status Button - only show when toggle is on
                            if settingsManager.settings.liveActivityEnabled {
                                Button(action: {
                                    if !liveActivitiesEnabledSystemwide {
                                        showLiveActivityHelp = true
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        if liveActivitiesEnabledSystemwide {
                                            // Green checkmark with transparent glass
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(Color(red: 0.67, green: 0.79, blue: 0.32)) // #aaca52
                                            
                                            Text("All Good")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.white.opacity(0.9))
                                        } else {
                                            // Red warning
                                            Image(systemName: "exclamationmark.triangle.fill")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.red)
                                            
                                            Text("Issues Found")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        Group {
                                            if liveActivitiesEnabledSystemwide {
                                                // Transparent glass effect for healthy state
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(.clear)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                                    )
                                            } else {
                                                // Red background for issues
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color.red.opacity(0.7))
                                            }
                                        }
                                    )
                                }
                                .disabled(liveActivitiesEnabledSystemwide) // Only clickable when red
                                
                                // Live Activity Gallery Button
                                NavigationLink(destination: LiveActivityGalleryView(initialDesign: settingsManager.settings.liveActivityDesign).environmentObject(settingsManager)) {
                                    HStack {
                                        Image(systemName: "rectangle.and.text.magnifyingglass")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white.opacity(0.7))
                                        
                                        Text("Live Activity Gallery")
                                            .font(.system(size: 16, weight: .regular, design: .default))
                                            .foregroundColor(.white.opacity(0.85))
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.clear)
                        )
                        .glassedEffect(in: RoundedRectangle(cornerRadius: 20), interactive: false)
                        
                        // Footer Section
                        VStack(spacing: 16) {
                            // Restore Defaults Button
                            Button(action: {
                                // Restore defaults logic
                            }) {
                                Text("Restore Defaults")
                                    .font(.system(size: 16, weight: .medium, design: .default))
                                    .foregroundColor(.white.opacity(0.7))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 25)
                                            .fill(Color.white.opacity(0.15))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 25)
                                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                                            )
                                    )
                            }
                            
                            // Version Info
                            Text("App Version 1.0.0 (2026 build)")
                                .font(.system(size: 12, weight: .regular, design: .default))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 20)
                    }
                }
                .onAppear {
                    startSettingsEntranceAnimation()
                    checkCalendarAuthorization()
                    if settingsManager.settings.liveActivityEnabled && !hasCheckedHealth {
                        checkLiveActivityHealth()
                        hasCheckedHealth = true
                    }
                    PerformanceLogger.event("SettingsView onAppear")
                }
            }
            .sheet(isPresented: $showingAudioManagement) {
                AudioManagementView()
            }
            .sheet(isPresented: $showLiveActivityHelp) {
                LiveActivityHelpSheet()
            }
            .alert("Enable Live Activities", isPresented: $showLiveActivityAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Live Activities appear disabled by system settings or Focus. Please enable: 1) Face ID & Passcode > Live Activities, 2) MyAzan > Live Activities, 3) In Focus, allow Lock Screen notifications.")
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
    
    private func startSettingsEntranceAnimation() {
        // Cards settle into place with staggered bounce
        for i in 0..<cardsScale.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.05) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    cardsScale[i] = 1.0
                    cardsOpacity[i] = 1.0
                    cardsBlur[i] = 0.0
                }
            }
        }
        
        // Haptic feedback when animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
    }
    
    private func checkCalendarAuthorization() {
        calendarAuthorizationStatus = EKEventStore.authorizationStatus(for: .event)
    }
    
    private func requestCalendarPermission() {
        let eventStore = EKEventStore()
        
        Task {
            do {
                let granted = try await eventStore.requestFullAccessToEvents()
                await MainActor.run {
                    calendarAuthorizationStatus = EKEventStore.authorizationStatus(for: .event)
                    if granted {
                        settingsManager.updateVibrationOnlyDuringMeetings(true)
                    }
                }
            } catch {
                print("Failed to request calendar access: \(error)")
                await MainActor.run {
                    calendarAuthorizationStatus = EKEventStore.authorizationStatus(for: .event)
                }
            }
        }
    }
    
    private func checkLiveActivityHealth() {
        let enabled = ActivityAuthorizationInfo().areActivitiesEnabled
        liveActivitiesEnabledSystemwide = enabled
        if !enabled {
            showLiveActivityAlert = true
        }
    }
}

// Enhanced Liquid Glass Card Component
struct EnhancedLiquidGlassCard<Content: View>: View {
    let content: Content
    let cardIndex: Int
    let cardsScale: [Double]
    let cardsOpacity: [Double]
    let cardsBlur: [Double]
    
    init(cardIndex: Int = 0, cardsScale: [Double] = [1.0], cardsOpacity: [Double] = [1.0], cardsBlur: [Double] = [3.0], @ViewBuilder content: () -> Content) {
        self.content = content()
        self.cardIndex = cardIndex
        self.cardsScale = cardsScale
        self.cardsOpacity = cardsOpacity
        self.cardsBlur = cardsBlur
    }
    
    var body: some View {
        content
            .scaleEffect(cardsScale.indices.contains(cardIndex) ? cardsScale[cardIndex] : 1.0)
            .opacity(cardsOpacity.indices.contains(cardIndex) ? cardsOpacity[cardIndex] : 1.0)
            .appCardStyleMaterial()
    }
}

// Custom iOS 26 Style Toggle
struct CustomToggle: View {
    @Binding var isOn: Bool
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isOn.toggle()
                animationOffset = isOn ? 20 : 0
            }
        }) {
            ZStack {
                // Background capsule with iOS 26 glass effect
                Capsule()
                    .fill(.regularMaterial)
                    .frame(width: 50, height: 30)
                    .overlay(
                        Capsule()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.6),
                                        Color.white.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
                
                // Toggle knob with lifted effect
                Circle()
                    .fill(.thickMaterial)
                    .frame(width: 26, height: 26)
                    .offset(x: animationOffset - 10)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.4), lineWidth: 0.5)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
            }
        }
        .onAppear {
            animationOffset = isOn ? 20 : 0
        }
    }
}

// Help sheet describing Live Activity requirements
struct LiveActivityHelpSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Required Settings")) {
                    Label("Face ID & Passcode → Live Activities ON", systemImage: "lock.fill")
                    Label("Settings → MyAzan → Live Activities ON", systemImage: "app.fill")
                    Label("Focus → Allow on Lock Screen", systemImage: "moon.fill")
                }
                Section(header: Text("Troubleshooting")) {
                    Label("Use a real device (not Simulator)", systemImage: "iphone")
                    Label("Wait 2–3s after toggling before locking", systemImage: "clock")
                    Label("Ensure notifications are allowed on Lock Screen", systemImage: "bell.fill")
                }
            }
            .navigationTitle("Live Activity Help")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }
        }
    }
}
