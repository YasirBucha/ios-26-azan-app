import Foundation

struct PrayerTime: Identifiable, Codable {
    var id = UUID()
    let name: String
    let arabicName: String
    let time: Date
    let isNext: Bool
    
    init(name: String, arabicName: String, time: Date, isNext: Bool = false) {
        self.name = name
        self.arabicName = arabicName
        self.time = time
        self.isNext = isNext
    }
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
    
    var timeRemaining: TimeInterval {
        return time.timeIntervalSinceNow
    }
    
    var isUpcoming: Bool {
        return timeRemaining > 0
    }
}
