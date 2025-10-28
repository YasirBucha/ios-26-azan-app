#!/bin/bash

# Test Live Activities Script for MyAzan
# This script helps you build and test different Live Activity designs

echo "🕌 MyAzan Live Activity Design Tester"
echo "====================================="
echo ""

# Check if we're in the right directory
if [ ! -f "MyAzan.xcodeproj/project.pbxproj" ]; then
    echo "❌ Error: Please run this script from the MyAzan project root directory"
    exit 1
fi

echo "📱 Available Live Activity Designs:"
echo "1. Liquid Glass (Current) - Modern, premium with rich animations"
echo "2. Minimalist - Clean, accessible, battery-friendly"
echo "3. Islamic Art - Traditional, culturally authentic with gold accents"
echo "4. Timeline - Information-dense, shows all prayers"
echo "5. Circular Progress - Unique, visually engaging circular layout"
echo ""

# Function to build and test a specific design
test_design() {
    local design_name=$1
    local widget_name=$2
    
    echo "🔨 Building $design_name design..."
    
    # Build the Live Activity target
    xcodebuild -project MyAzanLiveActivity.xcodeproj \
               -scheme MyAzanLiveActivity \
               -configuration Debug \
               -destination 'generic/platform=iOS' \
               build
    
    if [ $? -eq 0 ]; then
        echo "✅ $design_name design built successfully!"
        echo "📱 To test this design:"
        echo "   1. Connect your iPhone to your Mac"
        echo "   2. Open Xcode and select your device"
        echo "   3. Build and run the MyAzan app"
        echo "   4. The Live Activity will appear on your Lock Screen"
        echo ""
    else
        echo "❌ Failed to build $design_name design"
        echo ""
    fi
}

# Function to show how to switch designs
show_switch_instructions() {
    echo "🔄 How to Switch Between Designs:"
    echo "================================="
    echo ""
    echo "1. Open MyAzanLiveActivity/MyAzanLiveActivityBundle.swift"
    echo "2. Comment out the current design:"
    echo "   // PrayerLiveActivity()"
    echo ""
    echo "3. Uncomment the design you want to test:"
    echo "   MinimalistPrayerLiveActivity()"
    echo "   // or"
    echo "   IslamicArtPrayerLiveActivity()"
    echo "   // or"
    echo "   TimelinePrayerLiveActivity()"
    echo "   // or"
    echo "   CircularProgressPrayerLiveActivity()"
    echo ""
    echo "4. Build and run the app on your device"
    echo ""
}

# Function to show testing instructions
show_testing_instructions() {
    echo "🧪 How to Test Live Activities:"
    echo "==============================="
    echo ""
    echo "1. 📱 Physical Device Required:"
    echo "   - Live Activities only work on physical devices"
    echo "   - iPhone 14 Pro/Pro Max for Dynamic Island testing"
    echo "   - Any iPhone for Lock Screen testing"
    echo ""
    echo "2. 🔧 Setup Steps:"
    echo "   - Connect your iPhone to your Mac"
    echo "   - Open Xcode"
    echo "   - Select your device as the target"
    echo "   - Build and run the MyAzan app"
    echo ""
    echo "3. 📍 Where to See Live Activities:"
    echo "   - Lock Screen (swipe up to see all widgets)"
    echo "   - Dynamic Island (iPhone 14 Pro/Pro Max)"
    echo "   - Always-On Display (iPhone 14 Pro/Pro Max)"
    echo ""
    echo "4. 🎯 Testing Different States:"
    echo "   - Current prayer time (when prayer is active)"
    echo "   - Upcoming prayer (countdown to next prayer)"
    echo "   - Prayer transitions (when one prayer ends and next begins)"
    echo ""
}

# Main menu
echo "What would you like to do?"
echo "1. Build current design (Liquid Glass)"
echo "2. Show how to switch designs"
echo "3. Show testing instructions"
echo "4. Build all designs (for comparison)"
echo "5. Exit"
echo ""

read -p "Enter your choice (1-5): " choice

case $choice in
    1)
        test_design "Liquid Glass" "PrayerLiveActivity"
        ;;
    2)
        show_switch_instructions
        ;;
    3)
        show_testing_instructions
        ;;
    4)
        echo "🔨 Building all designs..."
        test_design "Liquid Glass" "PrayerLiveActivity"
        echo "Note: To test other designs, follow the switch instructions"
        ;;
    5)
        echo "👋 Goodbye!"
        exit 0
        ;;
    *)
        echo "❌ Invalid choice. Please run the script again."
        exit 1
        ;;
esac

echo ""
echo "💡 Pro Tips:"
echo "- Live Activities appear automatically when prayer times are loaded"
echo "- You can force-start a Live Activity from the app's home screen"
echo "- Test on different devices to see how designs adapt"
echo "- Check both light and dark mode appearances"
echo ""
