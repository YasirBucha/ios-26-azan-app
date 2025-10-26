import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var notificationManager: NotificationManager
    @StateObject private var audioFileManager = AudioFileManager.shared
    @StateObject private var audioManager = AudioManager()
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @State private var showingAudioManagement = false
    
    private var bgColors: [Color] {
        colorScheme == .dark 
            ? [Color.black, Color.blue.opacity(0.1)]
            : [Color.white, Color.blue.opacity(0.05)]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: bgColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Audio Settings
                        LiquidGlassBackground {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Audio Settings")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                // Azan Audio Toggle
                                HStack {
                                    Text("Azan Audio")
                                        .font(.body)
                                    Spacer()
                                    Toggle("", isOn: Binding(
                                        get: { settingsManager.settings.azanEnabled },
                                        set: { settingsManager.updateAzanEnabled($0) }
                                    ))
                                    .tint(.blue)
                                }
                                
                                // Audio File Selection
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Selected Audio")
                                        .font(.body)
                                    
                                    Picker("Audio File", selection: Binding(
                                        get: { 
                                            if settingsManager.settings.useDefaultAudio {
                                                return "default"
                                            } else if let id = settingsManager.settings.selectedAudioFileId {
                                                return id.uuidString
                                            }
                                            return "default"
                                        },
                                        set: { value in
                                            if value == "default" {
                                                settingsManager.updateUseDefaultAudio(true)
                                            } else if let id = UUID(uuidString: value) {
                                                settingsManager.updateSelectedAudioFile(id)
                                                settingsManager.updateUseDefaultAudio(false)
                                            }
                                        }
                                    )) {
                                        Text(audioFileManager.getDefaultAudioName()).tag("default")
                                        ForEach(audioFileManager.customAudioFiles) { file in
                                            Text(file.displayName).tag(file.id.uuidString)
                                        }
                                    }
                                    
                                    // Preview Button for Selected Audio
                                    HStack {
                                        Button(action: {
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
                                        }) {
                                            HStack {
                                                Image(systemName: (settingsManager.settings.useDefaultAudio && audioManager.isCurrentlyPlayingDefault()) || 
                                                      (!settingsManager.settings.useDefaultAudio && settingsManager.settings.selectedAudioFileId != nil && 
                                                       audioManager.isCurrentlyPlaying(settingsManager.settings.selectedAudioFileId!)) ? 
                                                      "stop.circle.fill" : "play.circle.fill")
                                                Text("Preview Audio")
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.blue.opacity(0.1))
                                            .foregroundColor(.blue)
                                            .cornerRadius(12)
                                        }
                                    }
                                }
                                
                                // Manage Audio Files Button
                                Button(action: {
                                    showingAudioManagement = true
                                }) {
                                    HStack {
                                        Image(systemName: "folder.badge.gearshape")
                                        Text("Manage Audio Files")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(12)
                                }
                            }
                            .padding()
                        }
                        
                        // Prayer Sound Settings
                        LiquidGlassBackground {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Prayer Sound Settings")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                // Bulk Controls
                                HStack(spacing: 12) {
                                    Button("Enable All") {
                                        settingsManager.enableAllPrayerSounds()
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(.green)
                                    
                                    Button("Disable All") {
                                        settingsManager.disableAllPrayerSounds()
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(.red)
                                    
                                    Spacer()
                                }
                                
                                Divider()
                                
                                // Individual Prayer Sound Controls
                                VStack(spacing: 12) {
                                    PrayerSoundToggleRow(
                                        prayerName: "Fajr",
                                        isEnabled: Binding(
                                            get: { settingsManager.settings.fajrSoundEnabled },
                                            set: { settingsManager.updateFajrSoundEnabled($0) }
                                        )
                                    )
                                    
                                    PrayerSoundToggleRow(
                                        prayerName: "Dhuhr",
                                        isEnabled: Binding(
                                            get: { settingsManager.settings.dhuhrSoundEnabled },
                                            set: { settingsManager.updateDhuhrSoundEnabled($0) }
                                        )
                                    )
                                    
                                    PrayerSoundToggleRow(
                                        prayerName: "Asr",
                                        isEnabled: Binding(
                                            get: { settingsManager.settings.asrSoundEnabled },
                                            set: { settingsManager.updateAsrSoundEnabled($0) }
                                        )
                                    )
                                    
                                    PrayerSoundToggleRow(
                                        prayerName: "Maghrib",
                                        isEnabled: Binding(
                                            get: { settingsManager.settings.maghribSoundEnabled },
                                            set: { settingsManager.updateMaghribSoundEnabled($0) }
                                        )
                                    )
                                    
                                    PrayerSoundToggleRow(
                                        prayerName: "Isha",
                                        isEnabled: Binding(
                                            get: { settingsManager.settings.ishaSoundEnabled },
                                            set: { settingsManager.updateIshaSoundEnabled($0) }
                                        )
                                    )
                                }
                            }
                            .padding()
                        }
                        
                        // Notification Settings
                        LiquidGlassBackground {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Notification Settings")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                // 5-minute Reminder Toggle
                                HStack {
                                    Text("5-minute Reminder")
                                        .font(.body)
                                    Spacer()
                                    Toggle("", isOn: Binding(
                                        get: { settingsManager.settings.reminderEnabled },
                                        set: { settingsManager.updateReminderEnabled($0) }
                                    ))
                                    .tint(.blue)
                                }
                                
                                // Live Activity Toggle
                                HStack {
                                    Text("Live Activity")
                                        .font(.body)
                                    Spacer()
                                    Toggle("", isOn: Binding(
                                        get: { settingsManager.settings.liveActivityEnabled },
                                        set: { settingsManager.updateLiveActivityEnabled($0) }
                                    ))
                                    .tint(.blue)
                                }
                            }
                            .padding()
                        }
                        
                        // Permissions Status
                        LiquidGlassBackground {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Permissions")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                HStack {
                                    Text("Notifications")
                                        .font(.body)
                                    Spacer()
                                    Text(notificationStatusText)
                                        .font(.caption)
                                        .foregroundColor(notificationStatusColor)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(notificationStatusColor.opacity(0.1), in: Capsule())
                                }
                                
                                if notificationManager.authorizationStatus == .denied {
                                    Button("Open Settings") {
                                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                                            UIApplication.shared.open(settingsUrl)
                                        }
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(.blue)
                                }
                            }
                            .padding()
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
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

