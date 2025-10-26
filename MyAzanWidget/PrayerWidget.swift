import WidgetKit
import SwiftUI
import Foundation

struct PrayerWidget: Widget {
    let kind: String = "PrayerWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerTimelineProvider()) { entry in
            PrayerWidgetEntryView(entry: entry)
                .containerBackground(.ultraThinMaterial, for: .widget)
        }
        .configurationDisplayName("Prayer Times")
        .description("Shows the next prayer time")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryCircular])
    }
}

struct PrayerTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> PrayerEntry {
        PrayerEntry(
            date: Date(),
            nextPrayer: PrayerTime(name: "Fajr", arabicName: "الفجر", time: Date().addingTimeInterval(3600), isNext: true),
            cityName: "Makkah"
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (PrayerEntry) -> ()) {
        let entry = PrayerEntry(
            date: Date(),
            nextPrayer: PrayerTime(name: "Dhuhr", arabicName: "الظهر", time: Date().addingTimeInterval(1800), isNext: true),
            cityName: "Makkah"
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
        
        // Create entries for the next 24 hours, updating every hour
        let currentDate = Date()
        for hourOffset in 0..<24 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            
            let entry = PrayerEntry(
                date: entryDate,
                nextPrayer: nextPrayer ?? PrayerTime(name: "Fajr", arabicName: "الفجر", time: entryDate.addingTimeInterval(3600), isNext: true),
                cityName: cityName
            )
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct PrayerEntry: TimelineEntry {
    let date: Date
    let nextPrayer: PrayerTime
    let cityName: String
}

struct PrayerWidgetEntryView: View {
    var entry: PrayerTimelineProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallPrayerWidgetView(entry: entry)
        case .systemMedium:
            MediumPrayerWidgetView(entry: entry)
        case .accessoryRectangular:
            AccessoryRectangularView(entry: entry)
        case .accessoryCircular:
            AccessoryCircularView(entry: entry)
        default:
            SmallPrayerWidgetView(entry: entry)
        }
    }
}

struct SmallPrayerWidgetView: View {
    let entry: PrayerEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.nextPrayer.arabicName)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(entry.nextPrayer.name)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(entry.nextPrayer.timeString)
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            Text(entry.cityName)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

struct MediumPrayerWidgetView: View {
    let entry: PrayerEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Next Prayer")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(entry.nextPrayer.arabicName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(entry.nextPrayer.name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(entry.nextPrayer.timeString)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(entry.cityName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if entry.nextPrayer.isUpcoming {
                    Text("in \(formatTimeRemaining(entry.nextPrayer.timeRemaining))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
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

struct AccessoryRectangularView: View {
    let entry: PrayerEntry
    
    var body: some View {
        HStack {
            Text(entry.nextPrayer.arabicName)
                .font(.caption)
                .fontWeight(.semibold)
            
            Spacer()
            
            Text(entry.nextPrayer.timeString)
                .font(.caption)
                .fontWeight(.bold)
        }
    }
}

struct AccessoryCircularView: View {
    let entry: PrayerEntry
    
    var body: some View {
        VStack(spacing: 2) {
            Text(entry.nextPrayer.timeString)
                .font(.caption)
                .fontWeight(.bold)
            
            Text(entry.nextPrayer.name)
                .font(.caption2)
        }
    }
}

#Preview(as: .systemSmall) {
    PrayerWidget()
} timeline: {
    PrayerEntry(
        date: Date(),
        nextPrayer: PrayerTime(name: "Fajr", arabicName: "الفجر", time: Date().addingTimeInterval(3600), isNext: true),
        cityName: "Makkah"
    )
}
