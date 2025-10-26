# iOS 26 Azan App - Xcode Configuration Guide

## 🚀 Quick Setup Checklist

### ✅ Step 1: Add Adhan Swift Package Dependency

1. **In Xcode, go to**: File → Add Package Dependencies
2. **Enter URL**: `https://github.com/batoulapps/adhan-swift`
3. **Select Version**: 2.0.0 or later
4. **Click**: Add Package
5. **Select**: "Adhan" from the list
6. **Click**: Add Package

### ✅ Step 2: Configure Main App Capabilities

**Select "MyAzan" target → Signing & Capabilities tab:**

1. **Location Capability:**
   - Click "+ Capability" → Location
   - Set to "Always and When In Use"

2. **Background Modes Capability:**
   - Click "+ Capability" → Background Modes
   - Enable: Background fetch
   - Enable: Remote notifications
   - Enable: Audio

3. **Push Notifications Capability:**
   - Click "+ Capability" → Push Notifications

4. **App Groups Capability:**
   - Click "+ Capability" → App Groups
   - Create new group: `group.com.myazan.app`
   - Enable the group

### ✅ Step 3: Configure Widget Capabilities

**Select "MyAzanWidget" target → Signing & Capabilities:**

1. **App Groups Capability:**
   - Click "+ Capability" → App Groups
   - Select existing group: `group.com.myazan.app`

### ✅ Step 4: Configure Live Activity Capabilities

**Select "MyAzanLiveActivity" target → Signing & Capabilities:**

1. **App Groups Capability:**
   - Click "+ Capability" → App Groups
   - Select existing group: `group.com.myazan.app`

### ✅ Step 5: Add Audio Files

**Replace placeholder files in MyAzan/Assets/ folder:**

1. **azan_makkah.mp3** - Makkah Azan recording
2. **azan_madinah.mp3** - Madinah Azan recording
3. **azan_cairo.mp3** - Cairo Azan recording
4. **azan_notification.wav** - Notification sound

**Audio Requirements:**
- Format: MP3 or WAV
- Duration: 2-5 minutes recommended
- Quality: 44.1kHz, 16-bit minimum
- File size: Keep under 5MB each

### ✅ Step 6: Build and Test

1. **Select Target Device**: iOS 18+ device or simulator
2. **Build**: Press Cmd+R
3. **Grant Permissions**: When prompted
4. **Test Features**: Verify all functionality works

## 🔧 Detailed Configuration

### Bundle Identifiers
- **Main App**: `com.myazan.app`
- **Widget**: `com.myazan.app.MyAzanWidget`
- **Live Activity**: `com.myazan.app.MyAzanLiveActivity`

### Deployment Target
- **Minimum iOS Version**: 18.0
- **Target iOS Version**: 18.0 (iOS 26)

### Required Permissions in Info.plist
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>My Azan needs access to your location to calculate accurate prayer times for your area.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>My Azan needs access to your location to calculate accurate prayer times and send notifications even when the app is closed.</string>
```

### Background Task Identifiers
- `com.myazan.refresh` - Daily prayer time updates
- `com.myazan.processing` - Background processing

## 🎯 Testing Checklist

### Core Features
- [ ] Location detection works
- [ ] Prayer times calculate correctly
- [ ] Azan audio plays
- [ ] Notifications appear at prayer times
- [ ] Settings save preferences

### iOS Integration
- [ ] Home screen widget shows prayer times
- [ ] Lock screen widget updates
- [ ] Live Activity countdown works
- [ ] Dynamic Island displays prayer info
- [ ] Background refresh updates times

### UI/UX
- [ ] Liquid Glass effects display properly
- [ ] Dark mode adaptation works
- [ ] Light mode adaptation works
- [ ] Animations are smooth
- [ ] Next prayer highlighting works

### Permissions
- [ ] Location permission granted
- [ ] Notification permission granted
- [ ] Background App Refresh enabled
- [ ] Live Activity permission granted

## 🐛 Common Issues & Solutions

### Prayer Times Not Updating
- **Check**: Location permissions in iOS Settings
- **Ensure**: Background App Refresh is enabled
- **Verify**: Internet connection for initial location

### Notifications Not Working
- **Check**: Notification permissions in iOS Settings
- **Ensure**: Do Not Disturb is not blocking notifications
- **Verify**: Notification settings in app

### Widget Not Updating
- **Check**: App Groups configuration
- **Restart**: Device to refresh widget data
- **Remove/Re-add**: Widget to home screen

### Live Activity Not Starting
- **Check**: Live Activity permissions in iOS Settings
- **Ensure**: Live Activity is enabled in app settings
- **Restart**: App to refresh Live Activity manager

### Build Errors
- **Check**: Adhan package is properly added
- **Verify**: All capabilities are configured
- **Ensure**: Bundle identifiers are unique
- **Clean**: Build folder (Cmd+Shift+K)

## 📱 Device Requirements

### Minimum Requirements
- **iOS**: 18.0 or later
- **Device**: iPhone 6s or later
- **Storage**: 50MB available space

### Recommended for Full Features
- **iOS**: 18.0+ (latest)
- **Device**: iPhone 12 or later (for Dynamic Island)
- **Storage**: 100MB available space

## 🎉 Success Indicators

Your app is ready when:
- ✅ Builds without errors
- ✅ Runs on device/simulator
- ✅ Location permission granted
- ✅ Prayer times display correctly
- ✅ Notifications work
- ✅ Widget appears on home screen
- ✅ Live Activity shows countdown
- ✅ Settings save preferences
- ✅ Audio plays correctly

## 📚 Additional Resources

- **GitHub Repository**: https://github.com/YasirBucha/ios-26-azan-app
- **Adhan Library**: https://github.com/batoulapps/adhan-swift
- **Apple Documentation**: https://developer.apple.com/documentation/
- **SwiftUI Guide**: https://developer.apple.com/tutorials/swiftui
- **WidgetKit Guide**: https://developer.apple.com/documentation/widgetkit
- **ActivityKit Guide**: https://developer.apple.com/documentation/activitykit

---

**Note**: This app uses cutting-edge iOS 26 features. Some features may not work in the iOS Simulator and require testing on a physical device.
