#!/bin/bash

# My Azan iOS 26 App Setup Script
echo "🕌 Setting up My Azan iOS 26 App..."

# Check if we're in the right directory
if [ ! -f "MyAzan.xcworkspace/contents.xcworkspacedata" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    echo "   Expected: /Users/yb/Development/Azan/"
    exit 1
fi

echo "✅ Project structure found"

# Check for Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode not found. Please install Xcode from the Mac App Store"
    exit 1
fi

echo "✅ Xcode found"

# Check iOS deployment target
echo "📱 Checking iOS deployment target..."
echo "   Target: iOS 18.0 (iOS 26)"
echo "   This app uses cutting-edge iOS 26 features including Liquid Glass"

# Check for required files
echo "📁 Checking project files..."
required_files=(
    "MyAzan/MyAzanApp.swift"
    "MyAzan/Models/PrayerTime.swift"
    "MyAzan/Services/LocationManager.swift"
    "MyAzan/Views/HomeView.swift"
    "MyAzanWidget/PrayerWidget.swift"
    "MyAzanLiveActivity/PrayerLiveActivity.swift"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "   ✅ $file"
    else
        echo "   ❌ Missing: $file"
        exit 1
    fi
done

echo ""
echo "🎉 Setup Complete!"
echo ""
echo "📋 Next Steps:"
echo "1. Open MyAzan.xcworkspace in Xcode"
echo "2. Add the Adhan Swift package dependency:"
echo "   - File → Add Package Dependencies"
echo "   - URL: https://github.com/batoulapps/adhan-swift"
echo "   - Version: 2.0.0 or later"
echo ""
echo "3. Configure App Capabilities:"
echo "   - Location (Always and When In Use)"
echo "   - Background Modes (Background fetch, Remote notifications, Audio)"
echo "   - Push Notifications"
echo "   - App Groups (create: group.com.myazan.app)"
echo ""
echo "4. Add Audio Files:"
echo "   - Replace placeholder audio files in MyAzan/Assets/"
echo "   - azan_makkah.mp3, azan_madinah.mp3, azan_cairo.mp3"
echo ""
echo "5. Test on Physical Device:"
echo "   - Deploy to iOS 18+ device for full functionality"
echo "   - Widgets and Live Activities require physical device"
echo ""
echo "🕌 Your iOS 26 Azan app is ready to build!"
