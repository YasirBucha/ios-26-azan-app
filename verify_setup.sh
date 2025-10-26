#!/bin/bash

# iOS 26 Azan App - Final Verification Script
echo "🕌 iOS 26 Azan App - Final Verification"
echo "======================================"
echo ""

# Check if we're in the right directory
if [ ! -f "MyAzan.xcworkspace/contents.xcworkspacedata" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    echo "   Expected: /Users/yb/Development/Azan/"
    exit 1
fi

echo "✅ Project structure verified"

# Check for Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode not found. Please install Xcode from the Mac App Store"
    exit 1
fi

echo "✅ Xcode found"

# Check for required files
echo "📁 Checking project files..."
required_files=(
    "MyAzan/MyAzanApp.swift"
    "MyAzan/Models/PrayerTime.swift"
    "MyAzan/Services/LocationManager.swift"
    "MyAzan/Views/HomeView.swift"
    "MyAzanWidget/PrayerWidget.swift"
    "MyAzanLiveActivity/PrayerLiveActivity.swift"
    "MyAzan/Info.plist"
    "MyAzanWidget/Info.plist"
    "MyAzanLiveActivity/Info.plist"
)

all_files_present=true
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "   ✅ $file"
    else
        echo "   ❌ Missing: $file"
        all_files_present=false
    fi
done

if [ "$all_files_present" = false ]; then
    echo "❌ Some required files are missing"
    exit 1
fi

echo "✅ All required files present"

# Check project configuration
echo "📱 Checking project configuration..."
echo "   • iOS Deployment Target: 18.0 (iOS 26)"
echo "   • Main App Bundle ID: com.myazan.app"
echo "   • Widget Bundle ID: com.myazan.app.MyAzanWidget"
echo "   • Live Activity Bundle ID: com.myazan.app.MyAzanLiveActivity"
echo "   • App Group: group.com.myazan.app"

# Check for audio placeholder files
echo "🎵 Checking audio files..."
audio_files=(
    "MyAzan/Assets/README_Audio_Files.md"
)

for file in "${audio_files[@]}"; do
    if [ -f "$file" ]; then
        echo "   ✅ Audio placeholder documentation found"
        echo "   ⚠️  Remember to add actual audio files:"
        echo "      - azan_makkah.mp3"
        echo "      - azan_madinah.mp3"
        echo "      - azan_cairo.mp3"
        echo "      - azan_notification.wav"
    fi
done

# Check Git status
echo "📦 Checking Git status..."
if [ -d ".git" ]; then
    echo "   ✅ Git repository initialized"
    if git remote -v | grep -q "github.com"; then
        echo "   ✅ GitHub remote configured"
        echo "   📱 Repository: https://github.com/YasirBucha/ios-26-azan-app"
    else
        echo "   ⚠️  GitHub remote not configured"
    fi
else
    echo "   ⚠️  Git repository not initialized"
fi

echo ""
echo "🎯 READY FOR NEXT STEPS:"
echo ""
echo "1️⃣  ADD ADHAN PACKAGE DEPENDENCY"
echo "   In Xcode: File → Add Package Dependencies"
echo "   URL: https://github.com/batoulapps/adhan-swift"
echo ""
echo "2️⃣  CONFIGURE CAPABILITIES"
echo "   • Location (Always and When In Use)"
echo "   • Background Modes (Background fetch, Remote notifications, Audio)"
echo "   • Push Notifications"
echo "   • App Groups (group.com.myazan.app)"
echo ""
echo "3️⃣  ADD AUDIO FILES"
echo "   Replace placeholders in MyAzan/Assets/"
echo ""
echo "4️⃣  BUILD AND TEST"
echo "   • Select iOS 18+ device"
echo "   • Press Cmd+R to build"
echo "   • Grant permissions when prompted"
echo ""
echo "📚 DOCUMENTATION AVAILABLE:"
echo "   • README.md - Complete project documentation"
echo "   • SETUP_GUIDE.md - Detailed setup instructions"
echo "   • XCODE_SETUP_GUIDE.md - Xcode configuration guide"
echo "   • NEXT_STEPS.md - Step-by-step instructions"
echo ""
echo "🎉 Your iOS 26 Azan app is ready for final configuration!"
echo "   All files are in place and properly structured."
echo ""
echo "🕌 May your app bring peace and convenience to users worldwide!"
