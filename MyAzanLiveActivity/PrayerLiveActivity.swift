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
        var progressPercentage: Double
        var isAzanEnabled: Bool
        var currentDate: Date
        var nextPrayerIndex: Int
        var allPrayerTimes: [String] // Array of formatted prayer times
        var currentPrayerStatus: String // "upcoming", "current", "passed"
    }
    
    var initialPrayerName: String
    var initialPrayerArabicName: String
    var initialPrayerTime: Date
    var cityName: String
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
    @State private var pulseScale: CGFloat = 1.0
    @State private var glowIntensity: Double = 0.3
    
    var body: some View {
        ZStack {
            // Enhanced Liquid Glass Background with iOS 18 features
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.05, green: 0.29, blue: 0.36), // #0d4a5d
                            Color(red: 0.04, green: 0.23, blue: 0.29),  // #0a3a4a
                            Color(red: 0.02, green: 0.18, blue: 0.22)   // #052e38
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                        .opacity(0.4)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.15),
                                    Color.white.opacity(0.05),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)
                .shadow(color: Color(red: 0.3, green: 0.72, blue: 1.0).opacity(glowIntensity), radius: 20, x: 0, y: 0)
            
            VStack(spacing: 20) {
                // Enhanced Header with Status Indicator
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("MY AZAN")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .tracking(1.2)
                        
                        // Status indicator
                        HStack(spacing: 6) {
                            Circle()
                                .fill(statusColor)
                                .frame(width: 6, height: 6)
                                .scaleEffect(pulseScale)
                                .animation(
                                    .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                                    value: pulseScale
                                )
                            
                            Text(statusText)
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    
                    Spacer()
                    
                    // Azan toggle indicator
                    if context.state.isAzanEnabled {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(red: 0.3, green: 0.72, blue: 1.0))
                    }
                }
                
                // Enhanced Main Prayer Info
                HStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(context.state.nextPrayerArabicName)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .opacity(breathingOpacity)
                            .animation(
                                .easeInOut(duration: 3.0).repeatForever(autoreverses: true),
                                value: breathingOpacity
                            )
                        
                        Text(context.state.nextPrayerName)
                            .font(.system(size: 16, weight: .medium, design: .default))
                            .foregroundColor(Color(red: 0.75, green: 0.83, blue: 0.85).opacity(0.8)) // #BFD3D8
                        
                        // Prayer index indicator
                        Text("Prayer \(context.state.nextPrayerIndex + 1) of 5")
                            .font(.system(size: 11, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 12) {
                        // Enhanced Time Display with Modern Ring
                        ZStack {
                            // Outer glow ring
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.3, green: 0.72, blue: 1.0).opacity(0.3),
                                            Color(red: 0.0, green: 1.0, blue: 0.88).opacity(0.2)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                                .frame(width: 80, height: 80)
                                .blur(radius: 4)
                            
                            // Main animated ring
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
                                .frame(width: 70, height: 70)
                                .rotationEffect(.degrees(shimmerOffset))
                                .animation(
                                    .linear(duration: 2.0).repeatForever(autoreverses: false),
                                    value: shimmerOffset
                                )
                            
                            // Time text
                            VStack(spacing: 2) {
                                Text(context.state.nextPrayerTime, style: .time)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Text("AM/PM")
                                    .font(.system(size: 8, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        
                        // Enhanced countdown
                        VStack(spacing: 4) {
                            Text("in \(formatTimeRemaining(context.state.timeRemaining))")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0.78, green: 0.89, blue: 0.91).opacity(0.9)) // #C7E3E8
                            
                            Text("until prayer")
                                .font(.system(size: 10, weight: .regular, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                
                // Enhanced Progress Section
                VStack(spacing: 8) {
                    HStack {
                        Text("Progress to Next Prayer")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Spacer()
                        
                        Text(context.state.cityName)
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(Color(red: 0.75, green: 0.83, blue: 0.85).opacity(0.7)) // #BFD3D8
                    }
                    
                    // Enhanced progress bar with iOS 18 styling
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background track
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 8)
                            
                            // Progress fill with enhanced gradient
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.3, green: 0.72, blue: 1.0),
                                            Color(red: 0.0, green: 1.0, blue: 0.88),
                                            Color(red: 0.3, green: 0.72, blue: 1.0)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * context.state.progressPercentage, height: 8)
                                .animation(.easeInOut(duration: 1.0), value: context.state.progressPercentage)
                                .shadow(color: Color(red: 0.3, green: 0.72, blue: 1.0).opacity(0.5), radius: 4, x: 0, y: 0)
                        }
                    }
                    .frame(height: 8)
                    
                    // Progress percentage
                    HStack {
                        Text("\(Int(context.state.progressPercentage * 100))%")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer()
                        
                        Text(context.state.currentDate, style: .date)
                            .font(.system(size: 10, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .padding(24)
        }
        .onAppear {
            breathingOpacity = 1.0
            shimmerOffset = 360
            pulseScale = 1.2
            glowIntensity = 0.5
        }
    }
    
    // MARK: - Computed Properties
    private var statusColor: Color {
        switch context.state.currentPrayerStatus {
        case "current":
            return Color(red: 0.0, green: 1.0, blue: 0.88) // #00FFE0
        case "upcoming":
            return Color(red: 0.3, green: 0.72, blue: 1.0) // #4DB8FF
        default:
            return Color.white.opacity(0.5)
        }
    }
    
    private var statusText: String {
        switch context.state.currentPrayerStatus {
        case "current":
            return "Prayer Time"
        case "upcoming":
            return "Upcoming"
        default:
            return "Scheduled"
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

// MARK: - Enhanced Dynamic Island Views
struct DynamicIslandLeadingView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                // Status indicator
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                    .scaleEffect(pulseScale)
                    .animation(
                        .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                        value: pulseScale
                    )
                
                Text(context.state.nextPrayerArabicName)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Text(context.state.nextPrayerName)
                .font(.system(size: 12, weight: .medium, design: .default))
                .foregroundColor(.white.opacity(0.8))
        }
        .onAppear {
            pulseScale = 1.2
        }
    }
    
    private var statusColor: Color {
        switch context.state.currentPrayerStatus {
        case "current":
            return Color(red: 0.0, green: 1.0, blue: 0.88) // #00FFE0
        case "upcoming":
            return Color(red: 0.3, green: 0.72, blue: 1.0) // #4DB8FF
        default:
            return Color.white.opacity(0.5)
        }
    }
}

struct DynamicIslandTrailingView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 6) {
            Text(context.state.nextPrayerTime, style: .time)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("in \(formatTimeRemaining(context.state.timeRemaining))")
                .font(.system(size: 12, weight: .medium, design: .default))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

struct DynamicIslandCenterView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            // Enhanced center design with rotating elements
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.3, green: 0.72, blue: 1.0).opacity(0.8),
                            Color(red: 0.0, green: 1.0, blue: 0.88).opacity(0.6),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 25
                    )
                )
                .frame(width: 50, height: 50)
                .rotationEffect(.degrees(rotationAngle))
                .animation(
                    .linear(duration: 4.0).repeatForever(autoreverses: false),
                    value: rotationAngle
                )
            
            // Prayer icon with enhanced styling
            Image(systemName: prayerIcon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
        }
        .onAppear {
            rotationAngle = 360
        }
    }
    
    private var prayerIcon: String {
        switch context.state.nextPrayerName.lowercased() {
        case "fajr":
            return "sunrise.fill"
        case "dhuhr":
            return "sun.max.fill"
        case "asr":
            return "sun.max.circle.fill"
        case "maghrib":
            return "sunset.fill"
        case "isha":
            return "moon.stars.fill"
        default:
            return "moon.stars.fill"
        }
    }
}

struct DynamicIslandBottomView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    
    var body: some View {
        HStack(spacing: 12) {
            // City name with location icon
            HStack(spacing: 4) {
                Image(systemName: "location.fill")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(red: 0.3, green: 0.72, blue: 1.0))
                
                Text(context.state.cityName)
                    .font(.system(size: 12, weight: .medium, design: .default))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            // Progress indicator
            HStack(spacing: 6) {
                Text("\(Int(context.state.progressPercentage * 100))%")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                
                // Mini progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 2)
                            .cornerRadius(1)
                        
                        Rectangle()
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
                            .frame(width: geometry.size.width * context.state.progressPercentage, height: 2)
                            .cornerRadius(1)
                    }
                }
                .frame(width: 30, height: 2)
            }
        }
    }
}

struct CompactLeadingView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(statusColor)
                .frame(width: 6, height: 6)
                .scaleEffect(pulseScale)
                .animation(
                    .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                    value: pulseScale
                )
            
            Text(context.state.nextPrayerArabicName)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .onAppear {
            pulseScale = 1.2
        }
    }
    
    private var statusColor: Color {
        switch context.state.currentPrayerStatus {
        case "current":
            return Color(red: 0.0, green: 1.0, blue: 0.88) // #00FFE0
        case "upcoming":
            return Color(red: 0.3, green: 0.72, blue: 1.0) // #4DB8FF
        default:
            return Color.white.opacity(0.5)
        }
    }
}

struct CompactTrailingView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(context.state.nextPrayerTime, style: .time)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("in \(formatTimeRemaining(context.state.timeRemaining))")
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

struct MinimalView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color(red: 0.3, green: 0.72, blue: 1.0))
                .frame(width: 4, height: 4)
                .scaleEffect(pulseScale)
                .animation(
                    .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                    value: pulseScale
                )
            
            Text(context.state.nextPrayerArabicName)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .onAppear {
            pulseScale = 1.2
        }
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
}