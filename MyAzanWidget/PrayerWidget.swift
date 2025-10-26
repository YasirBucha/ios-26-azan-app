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

// MARK: - Small Widget (1x1) - Circular Liquid Glass Card
struct SmallPrayerWidgetView: View {
    let entry: PrayerEntry
    
    var body: some View {
        ZStack {
            // Breathing glow effect
            Circle()
                .fill(Color(red: 0.3, green: 0.72, blue: 1.0).opacity(entry.breathingOpacity * 0.25)) // #4DB8FF40
                .frame(width: 120, height: 120)
                .blur(radius: 20)
            
            // Central circular Liquid Glass card
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 100, height: 100)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
            
            VStack(spacing: 4) {
                // Crescent icon
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(red: 0.3, green: 0.72, blue: 1.0)) // #4DB8FF
                
                // Arabic prayer name
                Text(entry.nextPrayer.arabicName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                
                // English prayer name
                Text(entry.nextPrayer.name)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
                
                // Time (bold, white 90%)
                Text(entry.nextPrayer.timeString)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                
                // Countdown (caption, #C7E3E8 70%)
                if entry.nextPrayer.isUpcoming {
                    Text("in \(formatTimeRemaining(entry.nextPrayer.timeRemaining))")
                        .font(.system(size: 8, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0.78, green: 0.89, blue: 0.91).opacity(0.7)) // #C7E3E8
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

// MARK: - Medium Widget (2x1) - Prayer List with Progress Bar
struct MediumPrayerWidgetView: View {
    let entry: PrayerEntry
    
    var body: some View {
        HStack(spacing: 16) {
            // Left side: Next prayer card
            VStack(alignment: .leading, spacing: 8) {
                Text("Next Prayer")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0.78, green: 0.89, blue: 0.91).opacity(0.7)) // #C7E3E8
                
                Text(entry.nextPrayer.arabicName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                
                Text(entry.nextPrayer.name)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
                
                Text(entry.nextPrayer.timeString)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.3, green: 0.72, blue: 1.0)) // #4DB8FF
                    .shadow(color: Color(red: 0.3, green: 0.72, blue: 1.0).opacity(0.5), radius: 4, x: 0, y: 0)
            }
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
            
            // Right side: Upcoming prayers list
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(entry.allPrayers.prefix(3).enumerated()), id: \.offset) { index, prayer in
                    HStack {
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
                    
                    if index < 2 {
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 1)
                            .padding(.vertical, 2)
                    }
                }
            }
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
        }
        .padding(16)
        
        // Animated progress bar below
        VStack(spacing: 8) {
            HStack {
                Text("Progress to Next Prayer")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                if entry.nextPrayer.isUpcoming {
                    Text("in \(formatTimeRemaining(entry.nextPrayer.timeRemaining))")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0.78, green: 0.89, blue: 0.91).opacity(0.7))
                }
            }
            
            // Gradient progress bar (#4DB8FF → #00FFE0)
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.3, green: 0.72, blue: 1.0), // #4DB8FF
                                    Color(red: 0.0, green: 1.0, blue: 0.88)  // #00FFE0
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * 0.6, height: 4)
                        .cornerRadius(2)
                        .opacity(entry.breathingOpacity)
                }
            }
            .frame(height: 4)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
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

// MARK: - Large Widget (2x2) - Full Prayer Schedule
struct LargePrayerWidgetView: View {
    let entry: PrayerEntry
    
    var body: some View {
        VStack(spacing: 16) {
            // Title
            HStack {
                Text("My Azan Schedule")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                
                Spacer()
                
                // Subtle animated particle shimmer
                Circle()
                    .fill(Color.white.opacity(entry.breathingOpacity * 0.05))
                    .frame(width: 4, height: 4)
                    .blur(radius: 2)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // Prayer grid
            VStack(spacing: 12) {
                ForEach(Array(entry.allPrayers.enumerated()), id: \.offset) { index, prayer in
                    HStack(spacing: 16) {
                        // Status indicator dot
                        Circle()
                            .fill(prayer.name == entry.nextPrayer.name ? 
                                  Color(red: 0.3, green: 0.72, blue: 1.0) : // #4DB8FF for next prayer
                                  Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .opacity(prayer.name == entry.nextPrayer.name ? entry.breathingOpacity : 1.0)
                        
                        // Arabic prayer name
                        Text(prayer.arabicName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 60, alignment: .leading)
                        
                        // English prayer name
                        Text(prayer.name)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Time
                        Text(prayer.timeString)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Footer
            HStack {
                Text(entry.cityName)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0.75, green: 0.83, blue: 0.85).opacity(0.6)) // #BFD3D8
                
                Spacer()
                
                Text(Date().formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0.75, green: 0.83, blue: 0.85).opacity(0.6))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
