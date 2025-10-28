import ActivityKit
import WidgetKit
import SwiftUI

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
