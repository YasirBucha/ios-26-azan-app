import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var notificationManager: NotificationManager
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
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
                                
                                // Voice Selection
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Azan Voice")
                                        .font(.body)
                                    
                                    Picker("Voice", selection: Binding(
                                        get: { settingsManager.settings.selectedVoice },
                                        set: { settingsManager.updateSelectedVoice($0) }
                                    )) {
                                        ForEach(AzanVoice.allCases, id: \.self) { voice in
                                            Text(voice.displayName).tag(voice)
                                        }
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
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
