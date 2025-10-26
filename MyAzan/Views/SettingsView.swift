import SwiftUI

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
    @State private var volumeLevel: Double = 0.8
    @State private var showingTestAnimation = false
    
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
                // Deep teal gradient background with soft light flare
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(red: 0.04, green: 0.23, blue: 0.29), // #0a3a4a
                            Color(red: 0.0, green: 0.12, blue: 0.15)  // #001e26
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
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
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Section
                        VStack(spacing: 8) {
                            Text("Settings")
                                .font(.system(size: 26, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text("Customize your prayer experience")
                                .font(.system(size: 15, weight: .regular, design: .default))
                                .foregroundColor(Color(red: 0.75, green: 0.83, blue: 0.85).opacity(0.7)) // #BFD3D8
                        }
                        .padding(.top, 40)
                        .padding(.bottom, 20)
                        
                        // Audio Settings Card
                        EnhancedLiquidGlassCard {
                            VStack(alignment: .leading, spacing: 20) {
                                Text("Audio Settings")
                                    .font(.system(size: 18, weight: .semibold, design: .default))
                                    .foregroundColor(.white.opacity(0.9))
                                
                                // Azan Voice Dropdown
                                HStack {
                                    Text("Azan Voice")
                                        .font(.system(size: 16, weight: .regular, design: .default))
                                        .foregroundColor(.white.opacity(0.85))
                                    Spacer()
                                    Text(audioFileManager.getDefaultAudioName())
                                        .font(.system(size: 16, weight: .medium, design: .default))
                                        .foregroundColor(.white.opacity(0.7))
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                
                                // Volume Level Slider
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Volume Level")
                                        .font(.system(size: 16, weight: .regular, design: .default))
                                        .foregroundColor(.white.opacity(0.85))
                                    
                                    HStack {
                                        Image(systemName: "speaker.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white.opacity(0.6))
                                        
                                        Slider(value: $volumeLevel, in: 0...1)
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
                                }
                                
                                // Play Test Azan Button
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showingTestAnimation.toggle()
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        if settingsManager.settings.useDefaultAudio {
                                            if audioManager.isCurrentlyPlayingDefault() {
                                                audioManager.stopAzan()
                                            } else {
                                                audioManager.previewAudio(useDefault: true)
                                            }
                                        } else if let id = settingsManager.settings.selectedAudioFileId {
                                            if audioManager.isCurrentlyPlaying(id) {
                                                audioManager.stopAzan()
                                            } else {
                                                audioManager.previewAudio(useDefault: false, customFileId: id)
                                            }
                                        }
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            showingTestAnimation = false
                                        }
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: (settingsManager.settings.useDefaultAudio && audioManager.isCurrentlyPlayingDefault()) || 
                                              (!settingsManager.settings.useDefaultAudio && settingsManager.settings.selectedAudioFileId != nil && 
                                               audioManager.isCurrentlyPlaying(settingsManager.settings.selectedAudioFileId!)) ? 
                                              "stop.circle.fill" : "play.circle.fill")
                                        Text("Play Test Azan")
                                    }
                                    .font(.system(size: 15, weight: .medium, design: .default))
                                    .foregroundColor(.white.opacity(0.9))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.ultraThinMaterial)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                                            )
                                    )
                                    .scaleEffect(showingTestAnimation ? 0.95 : 1.0)
                                }
                            }
                            .padding(20)
                        }
                        
                        // Notifications Card
                        EnhancedLiquidGlassCard {
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
                                    CustomToggle(isOn: Binding(
                                        get: { settingsManager.settings.azanEnabled },
                                        set: { settingsManager.updateAzanEnabled($0) }
                                    ))
                                }
                                
                                // Pre-Azan Reminder Toggle
                                HStack {
                                    Text("Pre-Azan Reminder (5 min before)")
                                        .font(.system(size: 16, weight: .regular, design: .default))
                                        .foregroundColor(.white.opacity(0.85))
                                    Spacer()
                                    CustomToggle(isOn: Binding(
                                        get: { settingsManager.settings.reminderEnabled },
                                        set: { settingsManager.updateReminderEnabled($0) }
                                    ))
                                }
                                
                                // Vibration Only Toggle
                                HStack {
                                    Text("Vibration Only During Meetings")
                                        .font(.system(size: 16, weight: .regular, design: .default))
                                        .foregroundColor(.white.opacity(0.85))
                                    Spacer()
                                    CustomToggle(isOn: Binding(
                                        get: { settingsManager.settings.liveActivityEnabled },
                                        set: { settingsManager.updateLiveActivityEnabled($0) }
                                    ))
                                }
                            }
                            .padding(20)
                        }
                        
                        // Appearance Card
                        EnhancedLiquidGlassCard {
                            VStack(alignment: .leading, spacing: 20) {
                                Text("Appearance")
                                    .font(.system(size: 18, weight: .semibold, design: .default))
                                    .foregroundColor(.white.opacity(0.9))
                                
                                // Theme Selector
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Theme")
                                        .font(.system(size: 16, weight: .regular, design: .default))
                                        .foregroundColor(.white.opacity(0.85))
                                    
                                    HStack(spacing: 8) {
                                        ForEach(ThemeMode.allCases, id: \.self) { theme in
                                            Button(action: {
                                                withAnimation(.easeInOut(duration: 0.3)) {
                                                    selectedTheme = theme
                                                }
                                            }) {
                                                Text(theme.rawValue)
                                                    .font(.system(size: 14, weight: .medium, design: .default))
                                                    .foregroundColor(selectedTheme == theme ? .white : .white.opacity(0.7))
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 8)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 20)
                                                            .fill(selectedTheme == theme ? 
                                                                  Color(red: 0.3, green: 0.72, blue: 1.0).opacity(0.8) : 
                                                                  Color.white.opacity(0.1))
                                                    )
                                            }
                                        }
                                    }
                                }
                                
                                // Accent Color Picker
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Accent Color")
                                        .font(.system(size: 16, weight: .regular, design: .default))
                                        .foregroundColor(.white.opacity(0.85))
                                    
                                    HStack(spacing: 12) {
                                        ForEach(AccentColor.allCases, id: \.self) { accent in
                                            Button(action: {
                                                withAnimation(.easeInOut(duration: 0.3)) {
                                                    selectedAccentColor = accent
                                                }
                                            }) {
                                                Circle()
                                                    .fill(accent.color)
                                                    .frame(width: 32, height: 32)
                                                    .overlay(
                                                        Circle()
                                                            .stroke(.white.opacity(0.3), lineWidth: selectedAccentColor == accent ? 3 : 1)
                                                    )
                                                    .scaleEffect(selectedAccentColor == accent ? 1.1 : 1.0)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(20)
                        }
                        
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
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAudioManagement) {
                AudioManagementView()
            }
        }
    }
    
    private var notificationStatusText: String {
        switch notificationManager.authorizationStatus {
        case .authorized:
            return "Enabled"
        case .denied:
            return "Disabled"
        case .notDetermined:
            return "Not Set"
        case .provisional:
            return "Provisional"
        case .ephemeral:
            return "Ephemeral"
        @unknown default:
            return "Unknown"
        }
    }
    
    private var notificationStatusColor: Color {
        switch notificationManager.authorizationStatus {
        case .authorized:
            return .green
        case .denied:
            return .red
        case .notDetermined:
            return .orange
        default:
            return .gray
        }
    }
}

struct PrayerSoundToggleRow: View {
    let prayerName: String
    @Binding var isEnabled: Bool
    
    var body: some View {
        HStack {
            Text(prayerName)
                .font(.body)
                .fontWeight(.medium)
            
            Spacer()
            
            Toggle("", isOn: $isEnabled)
                .tint(.blue)
        }
    }
}

