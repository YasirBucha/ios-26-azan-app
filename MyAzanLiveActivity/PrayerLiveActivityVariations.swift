import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Alternative Design Concepts for Live Activity

// MARK: 1. Minimalist Design
struct MinimalistPrayerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PrayerActivityAttributes.self) { context in
            MinimalistLockScreenView(context: context)
                .containerBackground(.clear, for: .widget)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    MinimalistLeadingView(context: context)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    MinimalistTrailingView(context: context)
                }
                
                DynamicIslandExpandedRegion(.center) {
                    MinimalistCenterView(context: context)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    MinimalistBottomView(context: context)
                }
            } compactLeading: {
                MinimalistCompactLeading(context: context)
            } compactTrailing: {
                MinimalistCompactTrailing(context: context)
            } minimal: {
                MinimalistMinimal(context: context)
            }
        }
    }
}

struct MinimalistLockScreenView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    
    var body: some View {
        VStack(spacing: 16) {
            // Clean header
            HStack {
                Text("MY AZAN")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .tracking(0.5)
                
                Spacer()
                
                Text(context.state.cityName)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.secondary)
            }
            
            // Main prayer info - clean typography
            VStack(spacing: 8) {
                Text(context.state.nextPrayerArabicName)
                    .font(.system(size: 32, weight: .light, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(context.state.nextPrayerName)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.secondary)
            }
            
            // Time and countdown - minimal design
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(context.state.nextPrayerTime, style: .time)
                        .font(.system(size: 24, weight: .medium, design: .monospaced))
                        .foregroundColor(.primary)
                    
                    Text("Prayer Time")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("in \(formatTimeRemaining(context.state.timeRemaining))")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("remaining")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondary)
                }
            }
            
            // Simple progress indicator
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 2)
                        .cornerRadius(1)
                    
                    Rectangle()
                        .fill(Color.accentColor)
                        .frame(width: geometry.size.width * context.state.progressPercentage, height: 2)
                        .cornerRadius(1)
                        .animation(.easeInOut(duration: 0.5), value: context.state.progressPercentage)
                }
            }
            .frame(height: 2)
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: 2. Islamic Art Inspired Design
struct IslamicArtPrayerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PrayerActivityAttributes.self) { context in
            IslamicArtLockScreenView(context: context)
                .containerBackground(.clear, for: .widget)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    IslamicArtLeadingView(context: context)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    IslamicArtTrailingView(context: context)
                }
                
                DynamicIslandExpandedRegion(.center) {
                    IslamicArtCenterView(context: context)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    IslamicArtBottomView(context: context)
                }
            } compactLeading: {
                IslamicArtCompactLeading(context: context)
            } compactTrailing: {
                IslamicArtCompactTrailing(context: context)
            } minimal: {
                IslamicArtMinimal(context: context)
            }
        }
    }
}

struct IslamicArtLockScreenView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            // Islamic geometric pattern background
            IslamicPatternBackground()
                .opacity(0.1)
            
            VStack(spacing: 20) {
                // Crescent moon header
                HStack {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.2))
                    
                    Text("MY AZAN")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.4))
                        .tracking(1.0)
                    
                    Spacer()
                    
                    Text(context.state.cityName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.6))
                }
                
                // Main prayer section with Islamic styling
                VStack(spacing: 16) {
                    // Arabic prayer name with decorative elements
                    HStack {
                        DecorativeElement()
                        
                        Text(context.state.nextPrayerArabicName)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.3))
                        
                        DecorativeElement()
                    }
                    
                    Text(context.state.nextPrayerName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 0.3, green: 0.4, blue: 0.5))
                }
                
                // Time display with Islamic geometric frame
                ZStack {
                    IslamicGeometricFrame()
                        .frame(width: 120, height: 80)
                    
                    VStack(spacing: 4) {
                        Text(context.state.nextPrayerTime, style: .time)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.3))
                        
                        Text("in \(formatTimeRemaining(context.state.timeRemaining))")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.6))
                    }
                }
                
                // Prayer progress with Islamic pattern
                IslamicProgressBar(progress: context.state.progressPercentage)
            }
            .padding(24)
        }
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.95, blue: 0.98),
                    Color(red: 0.92, green: 0.94, blue: 0.97)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onAppear {
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
    }
}

// MARK: 3. Timeline Design
struct TimelinePrayerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PrayerActivityAttributes.self) { context in
            TimelineLockScreenView(context: context)
                .containerBackground(.ultraThinMaterial, for: .widget)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    TimelineLeadingView(context: context)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    TimelineTrailingView(context: context)
                }
                
                DynamicIslandExpandedRegion(.center) {
                    TimelineCenterView(context: context)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    TimelineBottomView(context: context)
                }
            } compactLeading: {
                TimelineCompactLeading(context: context)
            } compactTrailing: {
                TimelineCompactTrailing(context: context)
            } minimal: {
                TimelineMinimal(context: context)
            }
        }
    }
}

struct TimelineLockScreenView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Prayer Times")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(context.state.cityName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            // Current prayer highlight
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(context.state.nextPrayerArabicName)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(context.state.nextPrayerName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(context.state.nextPrayerTime, style: .time)
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                    
                    Text("in \(formatTimeRemaining(context.state.timeRemaining))")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .padding(12)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            
            // Timeline of all prayers
            VStack(spacing: 8) {
                ForEach(Array(context.state.allPrayerTimes.enumerated()), id: \.offset) { index, prayerTime in
                    PrayerTimelineRow(
                        prayerIndex: index,
                        prayerTime: prayerTime,
                        isCurrent: index == context.state.nextPrayerIndex,
                        isPassed: index < context.state.nextPrayerIndex
                    )
                }
            }
        }
        .padding(20)
    }
}

// MARK: 4. Circular Progress Design
struct CircularProgressPrayerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PrayerActivityAttributes.self) { context in
            CircularProgressLockScreenView(context: context)
                .containerBackground(.ultraThinMaterial, for: .widget)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    CircularProgressLeadingView(context: context)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    CircularProgressTrailingView(context: context)
                }
                
                DynamicIslandExpandedRegion(.center) {
                    CircularProgressCenterView(context: context)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    CircularProgressBottomView(context: context)
                }
            } compactLeading: {
                CircularProgressCompactLeading(context: context)
            } compactTrailing: {
                CircularProgressCompactTrailing(context: context)
            } minimal: {
                CircularProgressMinimal(context: context)
            }
        }
    }
}

struct CircularProgressLockScreenView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("MY AZAN")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Text(context.state.cityName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            // Circular prayer times
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 2)
                    .frame(width: 200, height: 200)
                
                // Prayer time markers
                ForEach(0..<5) { index in
                    PrayerTimeMarker(
                        index: index,
                        isCurrent: index == context.state.nextPrayerIndex,
                        isPassed: index < context.state.nextPrayerIndex
                    )
                }
                
                // Center content
                VStack(spacing: 8) {
                    Text(context.state.nextPrayerArabicName)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(context.state.nextPrayerTime, style: .time)
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("in \(formatTimeRemaining(context.state.timeRemaining))")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // Progress indicator
            CircularProgressIndicator(progress: context.state.progressPercentage)
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.3, blue: 0.5),
                    Color(red: 0.05, green: 0.2, blue: 0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

// MARK: - Helper Views and Components

struct DecorativeElement: View {
    var body: some View {
        HStack(spacing: 2) {
            Circle().frame(width: 4, height: 4).foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.2))
            Circle().frame(width: 2, height: 2).foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.2))
            Circle().frame(width: 4, height: 4).foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.2))
        }
    }
}

struct IslamicPatternBackground: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                
                // Simple geometric pattern
                for i in stride(from: 0, to: width, by: 20) {
                    for j in stride(from: 0, to: height, by: 20) {
                        path.addEllipse(in: CGRect(x: i, y: j, width: 8, height: 8))
                    }
                }
            }
            .stroke(Color(red: 0.8, green: 0.6, blue: 0.2).opacity(0.3), lineWidth: 1)
        }
    }
}

struct IslamicGeometricFrame: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 0.8, green: 0.6, blue: 0.2), lineWidth: 2)
            
            // Corner decorations
            ForEach(0..<4) { _ in
                Circle()
                    .frame(width: 6, height: 6)
                    .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.2))
            }
        }
    }
}

struct IslamicProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color(red: 0.8, green: 0.6, blue: 0.2).opacity(0.2))
                    .frame(height: 6)
                    .cornerRadius(3)
                
                Rectangle()
                    .fill(Color(red: 0.8, green: 0.6, blue: 0.2))
                    .frame(width: geometry.size.width * progress, height: 6)
                    .cornerRadius(3)
                    .animation(.easeInOut(duration: 0.5), value: progress)
            }
        }
        .frame(height: 6)
    }
}

struct PrayerTimelineRow: View {
    let prayerIndex: Int
    let prayerTime: String
    let isCurrent: Bool
    let isPassed: Bool
    
    private let prayerNames = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"]
    
    var body: some View {
        HStack {
            // Status indicator
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            Text(prayerNames[prayerIndex])
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(textColor)
            
            Spacer()
            
            Text(prayerTime)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(textColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(isCurrent ? Color.accentColor.opacity(0.1) : Color.clear)
        .cornerRadius(6)
    }
    
    private var statusColor: Color {
        if isCurrent { return .accentColor }
        if isPassed { return .secondary }
        return .secondary.opacity(0.5)
    }
    
    private var textColor: Color {
        if isCurrent { return .primary }
        if isPassed { return .secondary }
        return .primary.opacity(0.7)
    }
}

struct PrayerTimeMarker: View {
    let index: Int
    let isCurrent: Bool
    let isPassed: Bool
    
    private let prayerNames = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"]
    private let angles: [Double] = [0, 72, 144, 216, 288] // 360/5 = 72 degrees each
    
    var body: some View {
        VStack {
            Circle()
                .fill(markerColor)
                .frame(width: 12, height: 12)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
            
            Text(prayerNames[index])
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
        .offset(y: -100)
        .rotationEffect(.degrees(angles[index]))
    }
    
    private var markerColor: Color {
        if isCurrent { return Color(red: 0.0, green: 1.0, blue: 0.88) }
        if isPassed { return Color.white.opacity(0.5) }
        return Color.white.opacity(0.8)
    }
}

struct CircularProgressIndicator: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 4)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [Color(red: 0.0, green: 1.0, blue: 0.88), Color(red: 0.3, green: 0.72, blue: 1.0)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: progress)
                
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .frame(width: 60, height: 60)
    }
}

// MARK: - Dynamic Island Views for Each Design

// Minimalist Dynamic Island Views
struct MinimalistLeadingView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(context.state.nextPrayerArabicName)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
            
            Text(context.state.nextPrayerName)
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(.secondary)
        }
    }
}

struct MinimalistTrailingView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(context.state.nextPrayerTime, style: .time)
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(.primary)
            
            Text("in \(formatTimeRemaining(context.state.timeRemaining))")
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(.secondary)
        }
    }
}

struct MinimalistCenterView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    
    var body: some View {
        Image(systemName: "moon.stars.fill")
            .font(.system(size: 16))
            .foregroundColor(.accentColor)
    }
}

struct MinimalistBottomView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    
    var body: some View {
        HStack {
            Text(context.state.cityName)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text("\(Int(context.state.progressPercentage * 100))%")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
        }
    }
}

struct MinimalistCompactLeading: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    
    var body: some View {
        Text(context.state.nextPrayerArabicName)
            .font(.system(size: 12, weight: .medium, design: .rounded))
            .foregroundColor(.primary)
    }
}

struct MinimalistCompactTrailing: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    
    var body: some View {
        Text(context.state.nextPrayerTime, style: .time)
            .font(.system(size: 12, weight: .medium, design: .monospaced))
            .foregroundColor(.primary)
    }
}

struct MinimalistMinimal: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    
    var body: some View {
        Text(context.state.nextPrayerArabicName)
            .font(.system(size: 12, weight: .medium, design: .rounded))
            .foregroundColor(.primary)
    }
}

// Placeholder views for other designs (similar structure)
struct IslamicArtLeadingView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    var body: some View { MinimalistLeadingView(context: context) }
}

struct IslamicArtTrailingView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    var body: some View { MinimalistTrailingView(context: context) }
}

struct IslamicArtCenterView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    var body: some View { MinimalistCenterView(context: context) }
}

struct IslamicArtBottomView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    var body: some View { MinimalistBottomView(context: context) }
}

struct IslamicArtCompactLeading: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    var body: some View { MinimalistCompactLeading(context: context) }
}

struct IslamicArtCompactTrailing: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    var body: some View { MinimalistCompactTrailing(context: context) }
}

struct IslamicArtMinimal: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    var body: some View { MinimalistMinimal(context: context) }
}

// Timeline design views
struct TimelineLeadingView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    var body: some View { MinimalistLeadingView(context: context) }
}

struct TimelineTrailingView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    var body: some View { MinimalistTrailingView(context: context) }
}

struct TimelineCenterView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    var body: some View { MinimalistCenterView(context: context) }
}

struct TimelineBottomView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    var body: some View { MinimalistBottomView(context: context) }
}

struct TimelineCompactLeading: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    var body: some View { MinimalistCompactLeading(context: context) }
}

struct TimelineCompactTrailing: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    var body: some View { MinimalistCompactTrailing(context: context) }
}

struct TimelineMinimal: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    var body: some View { MinimalistMinimal(context: context) }
}

// Circular progress design views
struct CircularProgressLeadingView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    var body: some View { MinimalistLeadingView(context: context) }
}

struct CircularProgressTrailingView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    var body: some View { MinimalistTrailingView(context: context) }
}

struct CircularProgressCenterView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    var body: some View { MinimalistCenterView(context: context) }
}

struct CircularProgressBottomView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    var body: some View { MinimalistBottomView(context: context) }
}

struct CircularProgressCompactLeading: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    var body: some View { MinimalistCompactLeading(context: context) }
}

struct CircularProgressCompactTrailing: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    var body: some View { MinimalistCompactTrailing(context: context) }
}

struct CircularProgressMinimal: View {
    let context: ActivityViewContext<PrayerActivityAttributes>
    var body: some View { MinimalistMinimal(context: context) }
}

// MARK: - Helper Function
private func formatTimeRemaining(_ timeInterval: TimeInterval) -> String {
    let hours = Int(timeInterval) / 3600
    let minutes = Int(timeInterval) % 3600 / 60
    
    if hours > 0 {
        return "\(hours)h \(minutes)m"
    } else {
        return "\(minutes)m"
    }
}
