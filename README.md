# iOS 26 Azan App - Native SwiftUI Prayer Times App

A beautiful, native iOS 26 app built with SwiftUI and Liquid Glass design that automatically detects your location and calculates accurate Islamic prayer times.

## Features

### 🕌 Core Functionality
- **Automatic Location Detection**: Uses CoreLocation to get your coordinates
- **Accurate Prayer Calculations**: Powered by the Adhan Swift library with Muslim World League method
- **Azan Audio Playback**: Plays beautiful Azan recordings with voice selection (Makkah, Madinah, Cairo)
- **Smart Notifications**: Local notifications for each prayer time with optional 5-minute reminders
- **Background Updates**: Automatic daily prayer time updates using BackgroundTasks

### 🎨 Modern UI with Liquid Glass
- **Liquid Glass Design**: Uses iOS 26's new glass materials and effects
- **Dark/Light Mode**: Automatically adapts to system appearance
- **Smooth Animations**: Delightful transitions and micro-interactions
- **Next Prayer Highlighting**: Beautiful emphasis on upcoming prayer times

### 📱 iOS Integration
- **Home Screen Widget**: Shows next prayer time on your home screen
- **Lock Screen Widget**: Prayer times accessible from lock screen
- **Live Activities**: Real-time countdown to next prayer on Lock Screen and Dynamic Island
- **Dynamic Island**: Compact prayer time display for supported devices

## Technical Stack

- **Language**: Swift 5+
- **UI Framework**: SwiftUI
- **Minimum iOS**: 18.0 (iOS 26)
- **Prayer Calculations**: Adhan Swift library
- **Location**: CoreLocation
- **Notifications**: UserNotifications
- **Audio**: AVFoundation
- **Background Tasks**: BackgroundTasks
- **Widgets**: WidgetKit
- **Live Activities**: ActivityKit
- **Data Persistence**: UserDefaults + App Groups

## Project Structure

```
MyAzan/
├── MyAzan/                          # Main app target
│   ├── MyAzanApp.swift             # App entry point
│   ├── Models/
│   │   ├── PrayerTime.swift        # Prayer time data model
│   │   └── AppSettings.swift       # User preferences
│   ├── Services/
│   │   ├── LocationManager.swift   # CoreLocation wrapper
│   │   ├── PrayerTimeService.swift # Adhan integration
│   │   ├── NotificationManager.swift # Local notifications
│   │   ├── AudioManager.swift     # Azan playback
│   │   ├── SettingsManager.swift  # UserDefaults persistence
│   │   ├── LiveActivityManager.swift # Live Activities
│   │   └── BackgroundTaskManager.swift # Background updates
│   ├── Views/
│   │   ├── HomeView.swift          # Main prayer times screen
│   │   ├── SettingsView.swift     # Configuration screen
│   │   └── Components/
│   │       ├── PrayerCard.swift   # Individual prayer card
│   │       └── LiquidGlassBackground.swift # Glass effect component
│   ├── Assets/
│   │   └── (audio files)          # Azan recordings
│   └── Info.plist                 # App configuration
├── MyAzanWidget/                   # WidgetKit extension
│   ├── PrayerWidget.swift         # Home/Lock screen widget
│   └── MyAzanWidgetBundle.swift   # Widget bundle
├── MyAzanLiveActivity/             # ActivityKit extension
│   ├── PrayerLiveActivity.swift   # Live Activity implementation
│   └── MyAzanLiveActivityBundle.swift # Activity bundle
└── Package.swift                  # Swift Package Manager
```

## Setup Instructions

### 1. Prerequisites
- Xcode 16+ (latest version)
- iOS 18+ device or simulator
- Apple Developer Account ($99/year)
- macOS with latest updates

### 2. Project Setup
1. Open Xcode and create a new iOS project
2. Set deployment target to iOS 18.0
3. Add the project files to your Xcode project
4. Configure capabilities in Xcode:
   - Location (Always and When In Use)
   - Background Modes (Background fetch, Remote notifications, Audio)
   - Push Notifications
   - App Groups (create group: `group.com.myazan.app`)

### 3. Dependencies
Add the Adhan Swift package:
1. File → Add Package Dependencies
2. Enter URL: `https://github.com/batoulapps/adhan-swift`
3. Select version 2.0.0 or later

### 4. Audio Files
Replace placeholder audio files in `Assets/` folder:
- `azan_makkah.mp3` - Makkah Azan recording
- `azan_madinah.mp3` - Madinah Azan recording
- `azan_cairo.mp3` - Cairo Azan recording
- `azan_notification.wav` - Notification sound

### 5. App Groups Configuration
1. In Xcode, go to your app target → Signing & Capabilities
2. Add "App Groups" capability
3. Create new group: `group.com.myazan.app`
4. Repeat for Widget and Live Activity targets

### 6. Background Tasks
The app automatically registers background tasks:
- `com.myazan.refresh` - Daily prayer time updates
- `com.myazan.processing` - Background processing

## Usage

### First Launch
1. Grant location permission when prompted
2. Grant notification permission for prayer alerts
3. The app automatically detects your location and calculates prayer times

### Settings
- **Azan Audio**: Toggle prayer call audio on/off
- **Voice Selection**: Choose between Makkah, Madinah, or Cairo voices
- **5-minute Reminder**: Get notified 5 minutes before each prayer
- **Live Activity**: Enable/disable Live Activity countdown

### Widgets
- Add "Prayer Times" widget to your home screen
- Widget shows next prayer name and time
- Updates automatically throughout the day

### Live Activities
- Live Activity appears on Lock Screen when enabled
- Shows countdown to next prayer
- Displays in Dynamic Island on supported devices
- Updates with smart frequency (more frequent when close to prayer time)

## Permissions Required

- **Location (When In Use)**: To calculate accurate prayer times for your area
- **Location (Always)**: To send notifications even when app is closed
- **Notifications**: To alert you at prayer times
- **Background App Refresh**: To update prayer times daily

## Privacy

- Location data is used only for prayer time calculations
- No data is sent to external servers
- All calculations are performed locally on your device
- Prayer times are cached locally for offline access

## Troubleshooting

### Prayer Times Not Updating
- Check location permissions in Settings
- Ensure Background App Refresh is enabled
- Verify internet connection for initial location detection

### Notifications Not Working
- Check notification permissions in Settings
- Ensure Do Not Disturb is not blocking notifications
- Verify notification settings in app

### Widget Not Updating
- Check App Groups configuration
- Restart device to refresh widget data
- Remove and re-add widget to home screen

### Live Activity Not Starting
- Check Live Activity permissions in Settings
- Ensure Live Activity is enabled in app settings
- Restart app to refresh Live Activity manager

## Development Notes

### Liquid Glass Implementation
The app uses iOS 26's new Liquid Glass APIs:
- `.background(.ultraThinMaterial)` for subtle glass effects
- `.background(.regularMaterial)` for more prominent glass
- Custom glass components with blur and depth

### Smart Update Frequency
Live Activities use intelligent update intervals:
- Every minute when <10 minutes remaining
- Every 5 minutes when 10-60 minutes remaining  
- Every 15 minutes when >60 minutes remaining

### Background Processing
- Daily prayer time recalculation at midnight
- Automatic notification rescheduling
- Minimal battery impact with efficient processing

## License

This project is for educational and personal use. Please respect Islamic prayer time calculation methods and use appropriate Azan recordings with proper permissions.

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Verify all permissions are granted
3. Ensure you're using iOS 18+ and latest Xcode
4. Test on physical device for full functionality

---

**Note**: This app requires iOS 18+ (iOS 26) and uses cutting-edge features like Liquid Glass design and Live Activities. Some features may not work in the iOS Simulator and require testing on a physical device.