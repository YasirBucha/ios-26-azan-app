import Foundation
import CoreLocation
import Combine

@MainActor
class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var cityName: String = "Unknown Location"
    private var lastLocationUpdate: Date?
    private var isRefreshingLocation = false
    
    override init() {
        super.init()
        // Defer heavy initialization
        DispatchQueue.main.async {
            self.setupLocationManager()
        }
        if let lastTimestamp = UserDefaults.standard.object(forKey: "lastLocationUpdate") as? TimeInterval {
            lastLocationUpdate = Date(timeIntervalSince1970: lastTimestamp)
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1000 // Update when moved 1km
        
        // Load cached city name
        Task { @MainActor in
            if let cachedCity = SharedDefaults.string(forKey: "cityName") {
                cityName = cachedCity
            }
        }
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startLocationUpdates() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            return
        }
        isRefreshingLocation = true
        locationManager.startUpdatingLocation()
    }

    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        isRefreshingLocation = false
    }

    func refreshLocationIfNeeded(force: Bool = false) {
        guard !isRefreshingLocation else { return }

        let shouldRefresh: Bool
        if force {
            shouldRefresh = true
        } else if let lastLocationUpdate {
            shouldRefresh = Date().timeIntervalSince(lastLocationUpdate) > 1800
        } else {
            shouldRefresh = true
        }

        guard shouldRefresh else { return }

        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        case .notDetermined:
            isRefreshingLocation = true
            requestLocationPermission()
        case .denied, .restricted:
            break
        @unknown default:
            break
        }
    }

    private func reverseGeocode(location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let placemark = placemarks?.first else { return }
            
            DispatchQueue.main.async {
                if let city = placemark.locality {
                    self?.cityName = city
                    Task { @MainActor in
                        SharedDefaults.set(city, forKey: "cityName")
                    }
                } else if let country = placemark.country {
                    self?.cityName = country
                    Task { @MainActor in
                        SharedDefaults.set(country, forKey: "cityName")
                    }
                }
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        Task { @MainActor in
            self.currentLocation = location
            self.reverseGeocode(location: location)
            self.lastLocationUpdate = Date()
            SharedDefaults.set(self.lastLocationUpdate?.timeIntervalSince1970, forKey: "lastLocationUpdate")
            self.stopLocationUpdates()
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Task { @MainActor in
            self.authorizationStatus = status

            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                if self.isRefreshingLocation {
                    self.startLocationUpdates()
                }
            case .denied, .restricted:
                self.stopLocationUpdates()
            case .notDetermined:
                break
            @unknown default:
                break
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
        Task { @MainActor in
            self.stopLocationUpdates()
        }
    }
}
