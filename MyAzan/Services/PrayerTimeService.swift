import Foundation
import Combine
// import Adhan // Temporarily commented out for testing

@MainActor
class PrayerTimeService: ObservableObject {
    @Published var prayerTimes: [PrayerTime] = []
    @Published var nextPrayer: PrayerTime?
    @Published var isLoading = false
    
    private var currentLatitude: Double = 0
    private var currentLongitude: Double = 0
    private var notificationManager: NotificationManager?
    private var settingsManager: SettingsManager?
    
    init() {
        PerformanceLogger.event("PrayerTimeService init")
        // Load cached data immediately for faster startup
        loadCachedPrayerTimes()
        
        // Defer heavy calculations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Always calculate prayer times on startup for now
            self.calculatePrayerTimes()
        }
    }
    
    func setManagers(notificationManager: NotificationManager, settingsManager: SettingsManager) {
        self.notificationManager = notificationManager
        self.settingsManager = settingsManager
    }
    
    private func scheduleNotifications() {
        guard let notificationManager = notificationManager,
              let settingsManager = settingsManager else { return }
        
        notificationManager.schedulePrayerNotifications(for: prayerTimes, settings: settingsManager.settings)
    }
    
    func updateLocation(latitude: Double, longitude: Double) {
        // Only update if location changed significantly (>5km)
        let distance = calculateDistance(from: (currentLatitude, currentLongitude), to: (latitude, longitude))
        
        if distance > 5000 || prayerTimes.isEmpty {
            currentLatitude = latitude
            currentLongitude = longitude
            calculatePrayerTimes()
        }
    }
    
    func calculatePrayerTimes() {
        // For now, always calculate mock prayer times regardless of location
        // TODO: Add location-based calculation when Adhan library is integrated
        
        isLoading = true
        PerformanceLogger.event("PrayerTimeService calculation started")
        
        Task.detached { [weak self] in
            guard let self = self else { return }
            
            // Temporary mock prayer times for testing (will be replaced with real Adhan calculations)
            let calendar = Calendar.current
            let today = Date()
            
            // Create mock prayer times based on location (will be replaced with real Adhan calculations)
            let mockTimes = [
                ("Fajr", "الفجر", calendar.date(bySettingHour: 5, minute: 30, second: 0, of: today) ?? today),
                ("Dhuhr", "الظهر", calendar.date(bySettingHour: 12, minute: 15, second: 0, of: today) ?? today),
                ("Asr", "العصر", calendar.date(bySettingHour: 15, minute: 45, second: 0, of: today) ?? today),
                ("Maghrib", "المغرب", calendar.date(bySettingHour: 18, minute: 20, second: 0, of: today) ?? today),
                ("Isha", "العشاء", calendar.date(bySettingHour: 19, minute: 50, second: 0, of: today) ?? today)
            ]
            
            var times: [PrayerTime] = []
            for (english, arabic, time) in mockTimes {
                times.append(PrayerTime(name: english, arabicName: arabic, time: time))
            }
            
            // Determine next prayer
            let now = Date()
            let upcomingPrayers = times.filter { $0.time > now }.sorted { $0.time < $1.time }
            
            if let next = upcomingPrayers.first {
                let nextPrayer = PrayerTime(name: next.name, arabicName: next.arabicName, time: next.time, isNext: true)
                
                await MainActor.run {
                    self.prayerTimes = times
                    self.nextPrayer = nextPrayer
                    self.isLoading = false
                    self.savePrayerTimes()
                    self.scheduleNotifications()
                    PerformanceLogger.event("PrayerTimeService calculation completed with next prayer \(nextPrayer.name)")
                }
            } else {
                // If no prayers left today, get first prayer of tomorrow
                let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
                let firstPrayerTomorrow = PrayerTime(name: "Fajr", arabicName: "الفجر", time: calendar.date(bySettingHour: 5, minute: 30, second: 0, of: tomorrow) ?? tomorrow, isNext: true)
                
                await MainActor.run {
                    self.prayerTimes = times
                    self.nextPrayer = firstPrayerTomorrow
                    self.isLoading = false
                    self.savePrayerTimes()
                    self.scheduleNotifications()
                    PerformanceLogger.event("PrayerTimeService calculation completed with tomorrow fallback")
                }
            }
        }
    }
    
    private func calculateDistance(from: (Double, Double), to: (Double, Double)) -> Double {
        let earthRadius = 6371000.0 // meters
        let lat1Rad = from.0 * .pi / 180
        let lat2Rad = to.0 * .pi / 180
        let deltaLatRad = (to.0 - from.0) * .pi / 180
        let deltaLonRad = (to.1 - from.1) * .pi / 180
        
        let a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
                cos(lat1Rad) * cos(lat2Rad) *
                sin(deltaLonRad / 2) * sin(deltaLonRad / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        
        return earthRadius * c
    }
    
    private func savePrayerTimes() {
        let encoder = JSONEncoder()
        
        if let data = try? encoder.encode(prayerTimes) {
            Task { @MainActor in
                SharedDefaults.set(data, forKey: "cachedPrayerTimes")
            }
        }
        
        if let nextPrayer = nextPrayer, let data = try? encoder.encode(nextPrayer) {
            Task { @MainActor in
                SharedDefaults.set(data, forKey: "cachedNextPrayer")
            }
        }
    }
    
    private func loadCachedPrayerTimes() {
        let decoder = JSONDecoder()
        
        Task { @MainActor in
            if let data = SharedDefaults.data(forKey: "cachedPrayerTimes"),
               let times = try? decoder.decode([PrayerTime].self, from: data) {
                prayerTimes = times
            }
            
            if let data = SharedDefaults.data(forKey: "cachedNextPrayer"),
               let next = try? decoder.decode(PrayerTime.self, from: data) {
                nextPrayer = next
            }
        }
    }
}
