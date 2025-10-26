# Live Activity Integration Guide

## Overview
The enhanced Live Activity system provides beautiful, real-time prayer time widgets that match the Liquid Glass aesthetic across Lock Screen, Dynamic Island, and Always-On Display.

## Key Features

### 🎨 **Visual Design**
- **Background**: Liquid Glass gradient (#0d4a5d → #0a3a4a) identical to app
- **Material**: `.ultraThinMaterial` overlay with subtle blur (radius ≈ 20pt)
- **Glow Accent**: #4DB8FF with animated shimmer effects
- **Corners**: Rounded (20pt Lock Screen, 12pt Dynamic Island)
- **Shadow**: x: 0, y: 3, blur: 8, color: #00000025
- **Typography**: SF Pro Rounded / SF Pro Text

### 📱 **Display Locations**
- **Lock Screen**: Centered glass capsule with animated progress ring
- **Dynamic Island**: Compact/expanded views with glass bubble effects
- **Always-On Display**: Optimized for low-power display

### ✨ **Animations & Effects**
- **Breathing Glow**: Prayer name opacity cycles (0.8 → 1.0 every 3s)
- **Shimmer Ring**: Animated gradient ring around time display
- **Progress Bar**: Smooth animated progress showing time until next prayer
- **Haptic Feedback**: Light haptic when countdown reaches 0

## Usage Example

```swift
// In your main app (e.g., HomeView or PrayerTimeService)
import ActivityKit

class PrayerTimeService: ObservableObject {
    @Published var liveActivityManager = LiveActivityManager()
    
    func startLiveActivity() {
        guard let nextPrayer = nextPrayer,
              let followingPrayer = getFollowingPrayer() else { return }
        
        liveActivityManager.startPrayerActivity(
            prayer: nextPrayer,
            nextPrayer: followingPrayer,
            cityName: locationManager.cityName,
            isAzanEnabled: settingsManager.settings.azanEnabled
        )
    }
    
    func updateLiveActivity() {
        guard let nextPrayer = nextPrayer,
              let followingPrayer = getFollowingPrayer() else { return }
        
        liveActivityManager.updatePrayerActivity(
            prayer: nextPrayer,
            nextPrayer: followingPrayer,
            cityName: locationManager.cityName,
            isAzanEnabled: settingsManager.settings.azanEnabled
        )
    }
    
    func stopLiveActivity() {
        liveActivityManager.stopActivity()
    }
}
```

## Data Structure

### Enhanced Attributes
```swift
struct PrayerActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var nextPrayerName: String
        var nextPrayerArabicName: String
        var nextPrayerTime: Date
        var timeRemaining: TimeInterval
        var cityName: String
        var nextPrayerName: String
        var nextPrayerTime: Date
        var progressPercentage: Double
        var isAzanEnabled: Bool
        var currentDate: Date
    }
    
    var initialPrayerName: String
    var initialPrayerArabicName: String
    var initialPrayerTime: Date
    var cityName: String
    var nextPrayerName: String
    var nextPrayerTime: Date
    var isAzanEnabled: Bool
}
```

## Widget Components

### Lock Screen View
- **App Header**: "MY AZAN" with small caps styling
- **Main Section**: Arabic + English prayer names with breathing glow
- **Time Display**: Large time with animated gradient ring
- **Countdown**: Time remaining with #C7E3E8 color
- **Progress Bar**: Animated bar showing progress to next prayer
- **Footer**: City name and current date

### Dynamic Island Views
- **Compact Leading**: Arabic prayer name
- **Compact Trailing**: Prayer time
- **Expanded Leading**: Arabic + English prayer names
- **Expanded Trailing**: Time + countdown
- **Expanded Center**: Crescent moon icon with radial glow
- **Expanded Bottom**: City + date
- **Minimal**: Arabic prayer name only

## Integration Steps

1. **Update Info.plist**: Ensure Live Activity capability is enabled
2. **Import ActivityKit**: Add to your main app target
3. **Initialize Manager**: Create LiveActivityManager instance
4. **Start Activity**: Call when prayer times are loaded
5. **Update Activity**: Call every minute or when prayer changes
6. **Stop Activity**: Call when app goes to background or user disables

## Best Practices

- **Update Frequency**: Update every minute for accurate countdown
- **Battery Optimization**: Use background refresh for updates
- **User Control**: Allow users to enable/disable Live Activities
- **Error Handling**: Gracefully handle ActivityKit errors
- **Testing**: Test on physical device (Live Activities don't work in simulator)

## Visual Consistency

The Live Activity widgets maintain perfect visual consistency with your app's Liquid Glass design:
- Same gradient backgrounds
- Matching typography and spacing
- Consistent glass materials and effects
- Unified color palette and animations

This creates a seamless, premium experience that extends your app's spiritual focus to the Lock Screen and Dynamic Island.
