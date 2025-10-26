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

struct PrayerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PrayerActivityAttributes.self) { context in
            LockScreenPrayerView(context: context)
                .containerBackground(.ultraThinMaterial, for: .widget)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    DynamicIslandLeadingView(context: context)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    DynamicIslandTrailingView(context: context)
                }
                
                DynamicIslandExpandedRegion(.center) {
                    DynamicIslandCenterView(context: context)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    DynamicIslandBottomView(context: context)
                }
            } compactLeading: {
                CompactLeadingView(context: context)
            } compactTrailing: {
                CompactTrailingView(context: context)
            } minimal: {
                MinimalView(context: context)
            }
        }
    }
}

// MARK: - Lock Screen View
struct LockScreenPrayerView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    @State private var breathingOpacity: Double = 0.8
    @State private var shimmerOffset: CGFloat = -200
    
    var body: some View {
        ZStack {
            // Liquid Glass Background
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.05, green: 0.29, blue: 0.36), // #0d4a5d
                            Color(red: 0.04, green: 0.23, blue: 0.29)  // #0a3a4a
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .opacity(0.3)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 3)
            
            VStack(spacing: 16) {
                // App Name Header
                Text("MY AZAN")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .tracking(1.2)
                
                // Main Prayer Info
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(context.state.nextPrayerArabicName)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .opacity(breathingOpacity)
                            .animation(
                                .easeInOut(duration: 3.0).repeatForever(autoreverses: true),
                                value: breathingOpacity
                            )
                        
                        Text(context.state.nextPrayerName)
                            .font(.system(size: 16, weight: .medium, design: .default))
                            .foregroundColor(Color(red: 0.75, green: 0.83, blue: 0.85).opacity(0.7)) // #BFD3D8
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        // Time with animated ring
                        ZStack {
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.3, green: 0.72, blue: 1.0), // #4DB8FF
                                            Color(red: 0.0, green: 1.0, blue: 0.88), // #00FFE0
                                            Color(red: 0.3, green: 0.72, blue: 1.0)  // #4DB8FF
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 3
                                )
                                .frame(width: 60, height: 60)
                                .rotationEffect(.degrees(shimmerOffset))
                                .animation(
                                    .linear(duration: 2.0).repeatForever(autoreverses: false),
                                    value: shimmerOffset
                                )
                            
                            Text(context.state.nextPrayerTime, style: .time)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        
                        Text("in \(formatTimeRemaining(context.state.timeRemaining))")
                            .font(.system(size: 14, weight: .medium, design: .default))
                            .foregroundColor(Color(red: 0.78, green: 0.89, blue: 0.91).opacity(0.7)) // #C7E3E8
                    }
                }
                
                // Progress Bar
                VStack(spacing: 4) {
                    HStack {
                        Text("Next: \(context.state.nextPrayerName)")
                            .font(.system(size: 12, weight: .medium, design: .default))
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                        Text(context.state.cityName)
                            .font(.system(size: 12, weight: .regular, design: .default))
                            .foregroundColor(Color(red: 0.75, green: 0.83, blue: 0.85).opacity(0.6)) // #BFD3D8
                    }
                    
                    // Animated progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 6)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.3, green: 0.72, blue: 1.0),
                                            Color(red: 0.0, green: 1.0, blue: 0.88)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * context.state.progressPercentage, height: 6)
                                .animation(.easeInOut(duration: 1.0), value: context.state.progressPercentage)
                        }
                    }
                    .frame(height: 6)
                }
            }
            .padding(20)
        }
        .onAppear {
            breathingOpacity = 1.0
            shimmerOffset = 360
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

// MARK: - Dynamic Island Views
struct DynamicIslandLeadingView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(context.state.nextPrayerArabicName)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(context.state.nextPrayerName)
                .font(.system(size: 12, weight: .medium, design: .default))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

struct DynamicIslandTrailingView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(context.state.nextPrayerTime, style: .time)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("in \(formatTimeRemaining(context.state.timeRemaining))")
                .font(.system(size: 12, weight: .medium, design: .default))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

struct DynamicIslandCenterView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.3, green: 0.72, blue: 1.0).opacity(0.8),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 20
                    )
                )
                .frame(width: 40, height: 40)
            
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
        }
    }
}

struct DynamicIslandBottomView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    
    var body: some View {
        HStack {
            Text(context.state.cityName)
                .font(.system(size: 12, weight: .medium, design: .default))
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(context.state.currentDate, style: .date)
                .font(.system(size: 12, weight: .regular, design: .default))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

struct CompactLeadingView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    
    var body: some View {
        Text(context.state.nextPrayerArabicName)
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundColor(.white)
    }
}

struct CompactTrailingView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    
    var body: some View {
        Text(context.state.nextPrayerTime, style: .time)
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundColor(.white)
    }
}

struct MinimalView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    
    var body: some View {
        Text(context.state.nextPrayerArabicName)
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundColor(.white)
    }
}

// MARK: - Helper Functions
private func formatTimeRemaining(_ timeInterval: TimeInterval) -> String {
    let hours = Int(timeInterval) / 3600
    let minutes = Int(timeInterval) % 3600 / 60
    
    if hours > 0 {
        return "\(hours)h \(minutes)m"
    } else {
        return "\(minutes)m"
    }
}