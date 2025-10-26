import ActivityKit
import WidgetKit
import SwiftUI

struct PrayerActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var nextPrayerName: String
        var nextPrayerArabicName: String
        var nextPrayerTime: Date
        var timeRemaining: TimeInterval
        var cityName: String
    }
    
    var initialPrayerName: String
    var initialPrayerArabicName: String
    var initialPrayerTime: Date
    var cityName: String
}

struct PrayerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PrayerActivityAttributes.self) { context in
            // Lock screen/banner UI goes here
            LockScreenPrayerView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading) {
                        Text(context.state.nextPrayerArabicName)
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text(context.state.nextPrayerName)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing) {
                        Text(context.state.nextPrayerTime, style: .time)
                            .font(.caption)
                            .fontWeight(.bold)
                        Text("in \(formatTimeRemaining(context.state.timeRemaining))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                DynamicIslandExpandedRegion(.center) {
                    Text("Next Prayer")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.cityName)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } compactLeading: {
                Text(context.state.nextPrayerArabicName)
                    .font(.caption)
                    .fontWeight(.semibold)
            } compactTrailing: {
                Text(context.state.nextPrayerTime, style: .time)
                    .font(.caption)
                    .fontWeight(.bold)
            } minimal: {
                Text(context.state.nextPrayerArabicName)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
        }
    }
    
    private func formatTimeRemaining(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct LockScreenPrayerView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Next Prayer")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(context.state.nextPrayerArabicName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(context.state.nextPrayerName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                Text(context.state.nextPrayerTime, style: .time)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text("in \(formatTimeRemaining(context.state.timeRemaining))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(context.state.cityName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }
    
    private func formatTimeRemaining(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
