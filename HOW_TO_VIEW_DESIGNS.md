# How to View Live Activity Designs

## Quick Start Guide

### 🚀 Method 1: Build and Test on Device (Recommended)

1. **Connect your iPhone** to your Mac via USB
2. **Open Xcode** and select your device
3. **Build and run** the MyAzan app
4. **Live Activities will appear** automatically on your Lock Screen

### 📱 Method 2: Use the Test Script

Run the test script I created for you:

```bash
cd /Users/yb/Development/Azan
./test_live_activities.sh
```

This will guide you through building and testing different designs.

## Step-by-Step Instructions

### Step 1: Switch Between Designs

To test different designs, edit this file:
**`MyAzanLiveActivity/MyAzanLiveActivityBundle.swift`**

```swift
@main
struct MyAzanLiveActivityBundle: WidgetBundle {
    var body: some Widget {
        // Current Liquid Glass Design (Default)
        PrayerLiveActivity()
        
        // Alternative Designs (Uncomment to test)
        // MinimalistPrayerLiveActivity()
        // IslamicArtPrayerLiveActivity()
        // TimelinePrayerLiveActivity()
        // CircularProgressPrayerLiveActivity()
    }
}
```

**To test a different design:**
1. Comment out the current design: `// PrayerLiveActivity()`
2. Uncomment the design you want: `MinimalistPrayerLiveActivity()`
3. Build and run the app

### Step 2: Build the App

**Option A: Using Xcode**
1. Open `MyAzan.xcworkspace` in Xcode
2. Select your iPhone as the target device
3. Press `Cmd + R` to build and run

**Option B: Using Command Line**
```bash
cd /Users/yb/Development/Azan
xcodebuild -workspace MyAzan.xcworkspace -scheme MyAzan -destination 'generic/platform=iOS' build
```

### Step 3: View Live Activities

**On Lock Screen:**
- Swipe up on your Lock Screen
- Look for the MyAzan Live Activity widget
- It will show the current prayer information

**On Dynamic Island (iPhone 14 Pro/Pro Max):**
- The Live Activity appears as a compact bubble
- Tap to expand and see more details
- Swipe to dismiss

**On Always-On Display (iPhone 14 Pro/Pro Max):**
- The Live Activity appears dimmed on the Always-On Display
- Shows essential prayer information

## Design Comparison

### 1. 🎨 Liquid Glass (Current)
- **File**: `PrayerLiveActivity.swift`
- **Style**: Modern, premium with rich animations
- **Colors**: Dark teal gradient with blue accents
- **Features**: Breathing glow, shimmer effects, animated progress ring

### 2. 🔳 Minimalist
- **File**: `PrayerLiveActivityVariations.swift` → `MinimalistPrayerLiveActivity`
- **Style**: Clean, typography-focused
- **Colors**: System colors (adapts to light/dark mode)
- **Features**: Simple progress bar, minimal animations

### 3. 🕌 Islamic Art
- **File**: `PrayerLiveActivityVariations.swift` → `IslamicArtPrayerLiveActivity`
- **Style**: Traditional Islamic aesthetics
- **Colors**: Cream background with gold accents
- **Features**: Geometric patterns, decorative elements

### 4. 📅 Timeline
- **File**: `PrayerLiveActivityVariations.swift` → `TimelinePrayerLiveActivity`
- **Style**: Information-dense timeline
- **Colors**: System colors with accent highlights
- **Features**: Shows all daily prayers, status indicators

### 5. ⭕ Circular Progress
- **File**: `PrayerLiveActivityVariations.swift` → `CircularProgressPrayerLiveActivity`
- **Style**: Unique circular layout
- **Colors**: Dark blue gradient with blue accents
- **Features**: Prayer markers around circle, radial progress

## Testing Different States

### Prayer States to Test:
1. **Current Prayer** - When prayer time is active
2. **Upcoming Prayer** - Countdown to next prayer
3. **Prayer Transition** - When one prayer ends and next begins
4. **End of Day** - Transition to next day's prayers

### Device Testing:
- **iPhone 14 Pro/Pro Max** - Test Dynamic Island functionality
- **iPhone 13/14** - Test Lock Screen and Always-On Display
- **iPhone SE** - Test compact layouts
- **iPad** - Test widget scaling

## Troubleshooting

### Live Activity Not Appearing?
1. **Check device**: Live Activities only work on physical devices
2. **Check permissions**: Ensure notifications are enabled
3. **Check location**: Make sure location services are enabled
4. **Restart app**: Force close and reopen the MyAzan app

### Build Errors?
1. **Clean build folder**: `Cmd + Shift + K` in Xcode
2. **Reset package cache**: File → Packages → Reset Package Caches
3. **Check iOS version**: Ensure device is running iOS 16.1 or later

### Design Not Changing?
1. **Check file**: Make sure you edited the correct file
2. **Clean build**: Clean build folder and rebuild
3. **Restart app**: Force close and reopen the app

## Quick Preview

If you want to see what each design looks like without building, check out:
- **`LIVE_ACTIVITY_VISUAL_COMPARISON.md`** - ASCII art mockups
- **`LIVE_ACTIVITY_DESIGN_OPTIONS.md`** - Detailed descriptions

## Pro Tips

1. **Test on multiple devices** to see how designs adapt
2. **Check both light and dark mode** appearances
3. **Test different prayer states** (current, upcoming, passed)
4. **Monitor battery usage** with different designs
5. **Get user feedback** on which design they prefer

## Need Help?

If you run into any issues:
1. Check the console output in Xcode
2. Verify your device is connected and trusted
3. Make sure you're running iOS 16.1 or later
4. Try cleaning and rebuilding the project

Happy testing! 🎉
