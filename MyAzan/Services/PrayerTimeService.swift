import Foundation
import Combine
import Adhan

class PrayerTimeService: ObservableObject {
    @Published var prayerTimes: [PrayerTime] = []
    @Published var nextPrayer: PrayerTime?
    @Published var isLoading = false
    
    private var currentLatitude: Double = 0
    private var currentLongitude: Double = 0
    private var calculationParameters: CalculationParameters
    
    init() {
        // Use Muslim World League calculation method
        self.calculationParameters = CalculationMethod.muslimWorldLeague.params
        loadCachedPrayerTimes()
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
        guard currentLatitude != 0 && currentLongitude != 0 else { return }
        
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let coordinates = Coordinates(latitude: self.currentLatitude, longitude: self.currentLongitude)
            let calendar = Calendar.current
            let today = Date()
            
            var times: [PrayerTime] = []
            
            // Calculate prayer times for today
            if let prayerTimes = PrayerTimes(coordinates: coordinates, date: today, calculationParameters: self.calculationParameters) {
                let prayers = [
                    ("Fajr", "الفجر", prayerTimes.fajr),
                    ("Dhuhr", "الظهر", prayerTimes.dhuhr),
                    ("Asr", "العصر", prayerTimes.asr),
                    ("Maghrib", "المغرب", prayerTimes.maghrib),
                    ("Isha", "العشاء", prayerTimes.isha)
                ]
                
                for (english, arabic, time) in prayers {
                    times.append(PrayerTime(name: english, arabicName: arabic, time: time))
                }
                
                // Determine next prayer
                let now = Date()
                let upcomingPrayers = times.filter { $0.time > now }.sorted { $0.time < $1.time }
                
                if let next = upcomingPrayers.first {
                    var nextPrayer = next
                    nextPrayer = PrayerTime(name: next.name, arabicName: next.arabicName, time: next.time, isNext: true)
                    
                    DispatchQueue.main.async {
                        self.prayerTimes = times
                        self.nextPrayer = nextPrayer
                        self.isLoading = false
                        self.savePrayerTimes()
                    }
                } else {
                    // If no prayers left today, get first prayer of tomorrow
                    let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
                    if let tomorrowPrayers = PrayerTimes(coordinates: coordinates, date: tomorrow, calculationParameters: self.calculationParameters) {
                        let firstPrayerTomorrow = PrayerTime(name: "Fajr", arabicName: "الفجر", time: tomorrowPrayers.fajr, isNext: true)
                        
                        DispatchQueue.main.async {
                            self.prayerTimes = times
                            self.nextPrayer = firstPrayerTomorrow
                            self.isLoading = false
                            self.savePrayerTimes()
                        }
                    }
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
        let sharedDefaults = UserDefaults(suiteName: "group.com.myazan.app")
        
        if let data = try? encoder.encode(prayerTimes) {
            UserDefaults.standard.set(data, forKey: "cachedPrayerTimes")
            sharedDefaults?.set(data, forKey: "cachedPrayerTimes")
        }
        
        if let nextPrayer = nextPrayer, let data = try? encoder.encode(nextPrayer) {
            UserDefaults.standard.set(data, forKey: "cachedNextPrayer")
            sharedDefaults?.set(data, forKey: "cachedNextPrayer")
        }
    }
    
    private func loadCachedPrayerTimes() {
        let decoder = JSONDecoder()
        
        if let data = UserDefaults.standard.data(forKey: "cachedPrayerTimes"),
           let times = try? decoder.decode([PrayerTime].self, from: data) {
            prayerTimes = times
        }
        
        if let data = UserDefaults.standard.data(forKey: "cachedNextPrayer"),
           let next = try? decoder.decode(PrayerTime.self, from: data) {
            nextPrayer = next
        }
    }
}
