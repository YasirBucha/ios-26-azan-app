import WidgetKit
import SwiftUI
import Foundation

struct PrayerWidget: Widget {
    let kind: String = "PrayerWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerTimelineProvider()) { entry in
            PrayerWidgetEntryView(entry: entry)
                .containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("My Azan")
        .description("Elegant prayer times with Liquid Glass design")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct PrayerTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> PrayerEntry {
        let mockPrayers = createMockPrayerTimes()
        return PrayerEntry(
            date: Date(),
            nextPrayer: mockPrayers.first!,
            allPrayers: mockPrayers,
            cityName: "Makkah",
            breathingOpacity: 0.8
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (PrayerEntry) -> ()) {
        let mockPrayers = createMockPrayerTimes()
        let entry = PrayerEntry(
            date: Date(),
            nextPrayer: mockPrayers.first!,
            allPrayers: mockPrayers,
            cityName: "Makkah",
            breathingOpacity: 0.8
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerEntry>) -> ()) {
        var entries: [PrayerEntry] = []
        
        // Load cached prayer times
        let decoder = JSONDecoder()
        var prayerTimes: [PrayerTime] = []
        var nextPrayer: PrayerTime?
        
        if let data = UserDefaults(suiteName: "group.com.myazan.app")?.data(forKey: "cachedPrayerTimes"),
           let times = try? decoder.decode([PrayerTime].self, from: data) {
            prayerTimes = times
        }
        
        if let data = UserDefaults(suiteName: "group.com.myazan.app")?.data(forKey: "cachedNextPrayer"),
           let next = try? decoder.decode(PrayerTime.self, from: data) {
            nextPrayer = next
        }
        
        let cityName = UserDefaults(suiteName: "group.com.myazan.app")?.string(forKey: "cityName") ?? "Unknown"
        
        // Use mock data if no cached data
        if prayerTimes.isEmpty {
            prayerTimes = createMockPrayerTimes()
            nextPrayer = prayerTimes.first
        }
        
        // Create entries for the next 24 hours, updating every hour
        let currentDate = Date()
        for hourOffset in 0..<24 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            
            // Calculate breathing opacity based on time (0.7 to 1.0 cycle)
            let breathingOpacity = 0.7 + 0.3 * sin(entryDate.timeIntervalSince1970 / 3.0)
            
            let entry = PrayerEntry(
                date: entryDate,
                nextPrayer: nextPrayer ?? prayerTimes.first!,
                allPrayers: prayerTimes,
                cityName: cityName,
                breathingOpacity: breathingOpacity
            )
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    private func createMockPrayerTimes() -> [PrayerTime] {
        let calendar = Calendar.current
        let today = Date()
        
        return [
            PrayerTime(name: "Fajr", arabicName: "الفجر", time: calendar.date(bySettingHour: 5, minute: 30, second: 0, of: today) ?? today),
            PrayerTime(name: "Dhuhr", arabicName: "الظهر", time: calendar.date(bySettingHour: 12, minute: 15, second: 0, of: today) ?? today),
            PrayerTime(name: "Asr", arabicName: "العصر", time: calendar.date(bySettingHour: 15, minute: 45, second: 0, of: today) ?? today),
            PrayerTime(name: "Maghrib", arabicName: "المغرب", time: calendar.date(bySettingHour: 18, minute: 20, second: 0, of: today) ?? today),
            PrayerTime(name: "Isha", arabicName: "العشاء", time: calendar.date(bySettingHour: 19, minute: 50, second: 0, of: today) ?? today)
        ]
    }
}

struct PrayerEntry: TimelineEntry {
    let date: Date
    let nextPrayer: PrayerTime
    let allPrayers: [PrayerTime]
    let cityName: String
    let breathingOpacity: Double
}

struct PrayerWidgetEntryView: View {
    var entry: PrayerTimelineProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        ZStack {
            // Liquid Glass Background
            LiquidGlassBackground()
            
            switch family {
            case .systemSmall:
                SmallPrayerWidgetView(entry: entry)
            case .systemMedium:
                MediumPrayerWidgetView(entry: entry)
            case .systemLarge:
                LargePrayerWidgetView(entry: entry)
            default:
                SmallPrayerWidgetView(entry: entry)
            }
        }
    }
}

// MARK: - Liquid Glass Background Component
struct LiquidGlassBackground: View {
    var body: some View {
        ZStack {
            // Deep teal gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.29, blue: 0.36), // #0d4a5d
                    Color(red: 0.04, green: 0.23, blue: 0.29)  // #0a3a4a
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Ultra thin material overlay
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
        }
    }
}

// MARK: - Enhanced Small Widget (1x1) - Modern Circular Design
struct SmallPrayerWidgetView: View {
    let entry: PrayerEntry
    @State private var pulseScale: CGFloat = 1.0
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            // Enhanced breathing glow effect with multiple layers
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.3, green: 0.72, blue: 1.0).opacity(entry.breathingOpacity * 0.3),
                            Color(red: 0.0, green: 1.0, blue: 0.88).opacity(entry.breathingOpacity * 0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)
                .blur(radius: 15)
                .scaleEffect(pulseScale)
                .animation(
                    .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                    value: pulseScale
                )
            
            // Enhanced circular Liquid Glass card with iOS 18 styling
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 110, height: 110)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.4),
                                    Color.white.opacity(0.1),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)
                .shadow(color: Color(red: 0.3, green: 0.72, blue: 1.0).opacity(0.3), radius: 8, x: 0, y: 0)
            
            VStack(spacing: 6) {
                // Enhanced prayer icon with rotation
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
                                endRadius: 12
                            )
                        )
                        .frame(width: 24, height: 24)
                        .rotationEffect(.degrees(rotationAngle))
                        .animation(
                            .linear(duration: 3.0).repeatForever(autoreverses: false),
                            value: rotationAngle
                        )
                    
                    Image(systemName: prayerIcon)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                }
                
                // Arabic prayer name with enhanced styling
                Text(entry.nextPrayer.arabicName)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.95))
                    .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                
                // English prayer name
                Text(entry.nextPrayer.name)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                
                // Enhanced time display
                Text(entry.nextPrayer.timeString)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.95))
                    .shadow(color: Color(red: 0.3, green: 0.72, blue: 1.0).opacity(0.5), radius: 2, x: 0, y: 0)
                
                // Enhanced countdown with status indicator
                if entry.nextPrayer.isUpcoming {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(red: 0.3, green: 0.72, blue: 1.0))
                            .frame(width: 4, height: 4)
                        
                        Text("in \(formatTimeRemaining(entry.nextPrayer.timeRemaining))")
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundColor(Color(red: 0.78, green: 0.89, blue: 0.91).opacity(0.8)) // #C7E3E8
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            pulseScale = 1.1
            rotationAngle = 360
        }
    }
    
    private var prayerIcon: String {
        switch entry.nextPrayer.name.lowercased() {
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

// MARK: - Enhanced Medium Widget (2x1) - Modern Prayer Dashboard
struct MediumPrayerWidgetView: View {
    let entry: PrayerEntry
    @State private var shimmerOffset: CGFloat = -200
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Enhanced Next Prayer Card
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Next Prayer")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0.78, green: 0.89, blue: 0.91).opacity(0.8)) // #C7E3E8
                        
                        Spacer()
                        
                        // Status indicator
                        Circle()
                            .fill(Color(red: 0.3, green: 0.72, blue: 1.0))
                            .frame(width: 6, height: 6)
                            .scaleEffect(pulseScale)
                            .animation(
                                .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                                value: pulseScale
                            )
                    }
                    
                    Text(entry.nextPrayer.arabicName)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.95))
                        .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                    
                    Text(entry.nextPrayer.name)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                    
                    Text(entry.nextPrayer.timeString)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.3, green: 0.72, blue: 1.0)) // #4DB8FF
                        .shadow(color: Color(red: 0.3, green: 0.72, blue: 1.0).opacity(0.6), radius: 4, x: 0, y: 0)
                }
                .padding(16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)
                .shadow(color: Color(red: 0.3, green: 0.72, blue: 1.0).opacity(0.2), radius: 8, x: 0, y: 0)
                
                // Enhanced Upcoming Prayers List
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today's Schedule")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0.78, green: 0.89, blue: 0.91).opacity(0.8))
                    
                    ForEach(Array(entry.allPrayers.prefix(3).enumerated()), id: \.offset) { index, prayer in
                        HStack(spacing: 8) {
                            // Prayer icon
                            Image(systemName: prayerIcon(for: prayer.name))
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color(red: 0.3, green: 0.72, blue: 1.0))
                                .frame(width: 16)
                            
                            Text(prayer.arabicName)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(width: 40, alignment: .leading)
                            
                            Text(prayer.name)
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.85))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text(prayer.timeString)
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.vertical, 4)
                        
                        if index < 2 {
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 1)
                                .padding(.vertical, 2)
                        }
                    }
                }
                .padding(16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)
                .shadow(color: Color(red: 0.3, green: 0.72, blue: 1.0).opacity(0.2), radius: 8, x: 0, y: 0)
            }
            
            // Enhanced Progress Section with iOS 18 styling
            VStack(spacing: 10) {
                HStack {
                    Text("Progress to Next Prayer")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    if entry.nextPrayer.isUpcoming {
                        Text("in \(formatTimeRemaining(entry.nextPrayer.timeRemaining))")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0.78, green: 0.89, blue: 0.91).opacity(0.8))
                    }
                }
                
                // Enhanced progress bar with animated shimmer
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background track
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 6)
                        
                        // Progress fill with enhanced gradient and shimmer
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.3, green: 0.72, blue: 1.0), // #4DB8FF
                                            Color(red: 0.0, green: 1.0, blue: 0.88), // #00FFE0
                                            Color(red: 0.3, green: 0.72, blue: 1.0)  // #4DB8FF
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * 0.6, height: 6)
                                .opacity(entry.breathingOpacity)
                            
                            // Shimmer effect
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.clear,
                                            Color.white.opacity(0.3),
                                            Color.clear
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * 0.6, height: 6)
                                .offset(x: shimmerOffset)
                                .animation(
                                    .linear(duration: 2.0).repeatForever(autoreverses: false),
                                    value: shimmerOffset
                                )
                        }
                    }
                }
                .frame(height: 6)
                
                // Progress percentage and city
                HStack {
                    Text("60% Complete")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text(entry.cityName)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0.75, green: 0.83, blue: 0.85).opacity(0.6))
                }
            }
        }
        .padding(16)
        .onAppear {
            pulseScale = 1.2
            shimmerOffset = 200
        }
    }
    
    private func prayerIcon(for prayerName: String) -> String {
        switch prayerName.lowercased() {
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

// MARK: - Enhanced Large Widget (2x2) - Complete Prayer Dashboard
struct LargePrayerWidgetView: View {
    let entry: PrayerEntry
    @State private var shimmerOffset: CGFloat = -200
    @State private var pulseScale: CGFloat = 1.0
    @State private var glowIntensity: Double = 0.3
    
    var body: some View {
        VStack(spacing: 20) {
            // Enhanced Header with Modern Styling
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("My Azan Schedule")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.95))
                        .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                    
                    Text("Today's Prayer Times")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0.78, green: 0.89, blue: 0.91).opacity(0.7))
                }
                
                Spacer()
                
                // Enhanced animated elements
                HStack(spacing: 8) {
                    // Status indicator
                    Circle()
                        .fill(Color(red: 0.3, green: 0.72, blue: 1.0))
                        .frame(width: 8, height: 8)
                        .scaleEffect(pulseScale)
                        .animation(
                            .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                            value: pulseScale
                        )
                    
                    // Glowing particle effect
                    Circle()
                        .fill(Color.white.opacity(glowIntensity))
                        .frame(width: 4, height: 4)
                        .blur(radius: 2)
                        .animation(
                            .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                            value: glowIntensity
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // Enhanced Prayer Grid with Modern Cards
            VStack(spacing: 16) {
                ForEach(Array(entry.allPrayers.enumerated()), id: \.offset) { index, prayer in
                    HStack(spacing: 16) {
                        // Enhanced status indicator with prayer-specific icons
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            prayer.name == entry.nextPrayer.name ? 
                                                Color(red: 0.3, green: 0.72, blue: 1.0).opacity(0.8) :
                                                Color.white.opacity(0.3),
                                            Color.clear
                                        ],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 12
                                    )
                                )
                                .frame(width: 24, height: 24)
                                .scaleEffect(prayer.name == entry.nextPrayer.name ? pulseScale : 1.0)
                                .animation(
                                    .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                                    value: pulseScale
                                )
                            
                            Image(systemName: prayerIcon(for: prayer.name))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                        }
                        
                        // Arabic prayer name with enhanced styling
                        Text(prayer.arabicName)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .frame(width: 70, alignment: .leading)
                            .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                        
                        // English prayer name
                        Text(prayer.name)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Enhanced time display
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(prayer.timeString)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.95))
                                .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                            
                            if prayer.name == entry.nextPrayer.name && prayer.isUpcoming {
                                Text("in \(formatTimeRemaining(prayer.timeRemaining))")
                                    .font(.system(size: 10, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(red: 0.78, green: 0.89, blue: 0.91).opacity(0.8))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.2),
                                        Color.white.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)
                    .shadow(
                        color: prayer.name == entry.nextPrayer.name ? 
                            Color(red: 0.3, green: 0.72, blue: 1.0).opacity(0.2) : 
                            Color.clear, 
                        radius: 8, x: 0, y: 0
                    )
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Enhanced Footer with Progress Bar
            VStack(spacing: 12) {
                // Progress section
                VStack(spacing: 8) {
                    HStack {
                        Text("Daily Progress")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Spacer()
                        
                        Text("\(Int(entry.breathingOpacity * 100))% Complete")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0.78, green: 0.89, blue: 0.91).opacity(0.8))
                    }
                    
                    // Enhanced progress bar with shimmer
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 8)
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
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
                                    .frame(width: geometry.size.width * entry.breathingOpacity, height: 8)
                                
                                // Shimmer effect
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.clear,
                                                Color.white.opacity(0.4),
                                                Color.clear
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * entry.breathingOpacity, height: 8)
                                    .offset(x: shimmerOffset)
                                    .animation(
                                        .linear(duration: 2.0).repeatForever(autoreverses: false),
                                        value: shimmerOffset
                                    )
                            }
                        }
                    }
                    .frame(height: 8)
                }
                
                // Footer info
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color(red: 0.3, green: 0.72, blue: 1.0))
                        
                        Text(entry.cityName)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Color(red: 0.75, green: 0.83, blue: 0.85).opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Text(Date().formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0.75, green: 0.83, blue: 0.85).opacity(0.7))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            pulseScale = 1.2
            shimmerOffset = 200
            glowIntensity = 0.5
        }
    }
    
    private func prayerIcon(for prayerName: String) -> String {
        switch prayerName.lowercased() {
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

// MARK: - Preview Providers
#Preview(as: .systemSmall) {
    PrayerWidget()
} timeline: {
    let mockPrayers = [
        PrayerTime(name: "Fajr", arabicName: "الفجر", time: Date().addingTimeInterval(3600), isNext: true),
        PrayerTime(name: "Dhuhr", arabicName: "الظهر", time: Date().addingTimeInterval(7200), isNext: false),
        PrayerTime(name: "Asr", arabicName: "العصر", time: Date().addingTimeInterval(10800), isNext: false),
        PrayerTime(name: "Maghrib", arabicName: "المغرب", time: Date().addingTimeInterval(14400), isNext: false),
        PrayerTime(name: "Isha", arabicName: "العشاء", time: Date().addingTimeInterval(18000), isNext: false)
    ]
    
    PrayerEntry(
        date: Date(),
        nextPrayer: mockPrayers.first!,
        allPrayers: mockPrayers,
        cityName: "Makkah",
        breathingOpacity: 0.8
    )
}

#Preview(as: .systemMedium) {
    PrayerWidget()
} timeline: {
    let mockPrayers = [
        PrayerTime(name: "Fajr", arabicName: "الفجر", time: Date().addingTimeInterval(3600), isNext: true),
        PrayerTime(name: "Dhuhr", arabicName: "الظهر", time: Date().addingTimeInterval(7200), isNext: false),
        PrayerTime(name: "Asr", arabicName: "العصر", time: Date().addingTimeInterval(10800), isNext: false),
        PrayerTime(name: "Maghrib", arabicName: "المغرب", time: Date().addingTimeInterval(14400), isNext: false),
        PrayerTime(name: "Isha", arabicName: "العشاء", time: Date().addingTimeInterval(18000), isNext: false)
    ]
    
    PrayerEntry(
        date: Date(),
        nextPrayer: mockPrayers.first!,
        allPrayers: mockPrayers,
        cityName: "Makkah",
        breathingOpacity: 0.8
    )
}

#Preview(as: .systemLarge) {
    PrayerWidget()
} timeline: {
    let mockPrayers = [
        PrayerTime(name: "Fajr", arabicName: "الفجر", time: Date().addingTimeInterval(3600), isNext: true),
        PrayerTime(name: "Dhuhr", arabicName: "الظهر", time: Date().addingTimeInterval(7200), isNext: false),
        PrayerTime(name: "Asr", arabicName: "العصر", time: Date().addingTimeInterval(10800), isNext: false),
        PrayerTime(name: "Maghrib", arabicName: "المغرب", time: Date().addingTimeInterval(14400), isNext: false),
        PrayerTime(name: "Isha", arabicName: "العشاء", time: Date().addingTimeInterval(18000), isNext: false)
    ]
    
    PrayerEntry(
        date: Date(),
        nextPrayer: mockPrayers.first!,
        allPrayers: mockPrayers,
        cityName: "Makkah",
        breathingOpacity: 0.8
    )
}
