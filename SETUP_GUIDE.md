# My Azan iOS 26 - Complete Setup Guide

## 🚀 Quick Start (5 minutes)

### 1. Add Adhan Swift Package Dependency
In Xcode:
1. **File** → **Add Package Dependencies**
2. **Enter URL**: `https://github.com/batoulapps/adhan-swift`
3. **Select Version**: 2.0.0 or later
4. **Click Add Package**
5. **Select "Adhan"** and click **Add Package**

### 2. Configure App Capabilities
In Xcode, select your **MyAzan** target:

**Signing & Capabilities Tab:**
1. **Click "+ Capability"** and add:
   - **Location** (Always and When In Use)
   - **Background Modes** (Background fetch, Remote notifications, Audio)
   - **Push Notifications**
   - **App Groups** (create new group: `group.com.myazan.app`)

### 3. Add Audio Files
Replace placeholder files in `MyAzan/Assets/`:
- `azan_makkah.mp3` - Makkah Azan recording
- `azan_madinah.mp3` - Madinah Azan recording  
- `azan_cairo.mp3` - Cairo Azan recording
- `azan_notification.wav` - Notification sound

### 4. Build and Run
1. **Select your target device** (iOS 18+ required)
2. **Press Cmd+R** to build and run
3. **Grant permissions** when prompted

## ✅ What's Already Done

- ✅ Complete SwiftUI app with Liquid Glass design
- ✅ Prayer time calculation using Adhan library
- ✅ Location detection and automatic updates
- ✅ Notification system with smart scheduling
- ✅ Audio playback with voice selection
- ✅ Home screen and lock screen widgets
- ✅ Live Activities with Dynamic Island support
- ✅ Background tasks for daily updates
- ✅ Settings screen with all preferences
- ✅ App Groups for data sharing

## 🎯 Features Ready to Use

### 🕌 Core Prayer Features
- **Automatic Location Detection**: Gets your coordinates automatically
- **Accurate Prayer Times**: Uses Muslim World League calculation method
- **Azan Audio**: Plays beautiful Azan recordings (3 voice options)
- **Smart Notifications**: Alerts at prayer times + 5-minute reminders
- **Background Updates**: Daily prayer time recalculation

### 🎨 Modern UI (iOS 26 Liquid Glass)
- **Liquid Glass Design**: Translucent backgrounds with blur effects
- **Dark/Light Mode**: Automatic system appearance adaptation
- **Smooth Animations**: Delightful transitions and micro-interactions
- **Next Prayer Highlighting**: Beautiful emphasis on upcoming prayer

### 📱 iOS Integration
- **Home Screen Widget**: Shows next prayer time
- **Lock Screen Widget**: Prayer times on lock screen
- **Live Activities**: Real-time countdown on Lock Screen and Dynamic Island
- **Dynamic Island**: Compact prayer display for supported devices

## 🔧 Technical Details

### Required Permissions
- **Location (When In Use)**: Calculate accurate prayer times
- **Location (Always)**: Send notifications when app is closed
- **Notifications**: Alert at prayer times
- **Background App Refresh**: Update prayer times daily

### App Groups Configuration
- **Group ID**: `group.com.myazan.app`
- **Purpose**: Share prayer times between app, widgets, and live activities
- **Data**: Prayer times, city name, settings

### Background Tasks
- **Daily Refresh**: Updates prayer times at midnight
- **Smart Processing**: Minimal battery impact
- **Automatic Scheduling**: Reschedules notifications daily

## 🐛 Troubleshooting

### Prayer Times Not Updating
- Check location permissions in iOS Settings
- Ensure Background App Refresh is enabled
- Verify internet connection for initial location

### Notifications Not Working
- Check notification permissions in iOS Settings
- Ensure Do Not Disturb is not blocking notifications
- Verify notification settings in app

### Widget Not Updating
- Check App Groups configuration
- Restart device to refresh widget data
- Remove and re-add widget to home screen

### Live Activity Not Starting
- Check Live Activity permissions in iOS Settings
- Ensure Live Activity is enabled in app settings
- Restart app to refresh Live Activity manager

## 📱 Testing Checklist

- [ ] Test on physical iOS 18+ device (simulator has limitations)
- [ ] Verify location detection works
- [ ] Check prayer time calculations are accurate
- [ ] Test notification delivery
- [ ] Verify widget updates correctly
- [ ] Test Live Activity countdown
- [ ] Check background refresh works
- [ ] Test in both light and dark modes
- [ ] Verify audio playback works
- [ ] Check settings persistence

## 🎉 You're Ready!

Your iOS 26 Azan app is complete and ready to use. It features:
- **Cutting-edge Liquid Glass design**
- **Automatic prayer time calculation**
- **Beautiful Azan audio playback**
- **Smart notifications and widgets**
- **Live Activities with Dynamic Island**

Just follow the Quick Start steps above and you'll have a fully functional prayer times app running on your device!
