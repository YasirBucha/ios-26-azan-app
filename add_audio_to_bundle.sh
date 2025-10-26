#!/bin/bash

echo "🔧 Adding azan_notification.mp3 to Xcode project bundle..."

# Navigate to project directory
cd /Users/yb/Development/Azan

# Check if file exists
if [ ! -f "MyAzan/Assets/azan_notification.mp3" ]; then
    echo "❌ Audio file not found at MyAzan/Assets/azan_notification.mp3"
    exit 1
fi

echo "✅ Audio file found"

# Instructions for manual addition
echo ""
echo "📋 MANUAL STEPS REQUIRED:"
echo "1. Open Xcode project (already opened)"
echo "2. Right-click on 'MyAzan' folder in the project navigator"
echo "3. Select 'Add Files to MyAzan...'"
echo "4. Navigate to and select: MyAzan/Assets/azan_notification.mp3"
echo "5. Make sure 'Add to target: MyAzan' is checked"
echo "6. Click 'Add'"
echo ""
echo "🔍 VERIFICATION:"
echo "After adding, you should see azan_notification.mp3 in the project navigator"
echo "The file should appear under the MyAzan folder"
echo ""
echo "🚀 ALTERNATIVE: Use Xcode's drag-and-drop:"
echo "1. Open Finder and navigate to: /Users/yb/Development/Azan/MyAzan/Assets/"
echo "2. Drag azan_notification.mp3 from Finder into Xcode project navigator"
echo "3. Drop it under the MyAzan folder"
echo "4. Ensure 'Copy items if needed' and 'Add to target: MyAzan' are checked"
echo "5. Click 'Finish'"
echo ""
echo "✅ Once added, the audio will work on both simulator and device!"
