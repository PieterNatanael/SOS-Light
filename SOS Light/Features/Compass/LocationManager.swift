import CoreLocation

final class CompassLocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    @Published var heading: Double = 0
    @Published var altitude: Double = 0
    @Published var accuracy: CLLocationAccuracy = 0
    @Published var coordinates: CLLocationCoordinate2D?

    @Published var placeName: String = "Unknown Location"
    @Published var country: String = ""
    @Published var administrativeArea: String = ""
    @Published var subAdministrativeArea: String = ""
    @Published var locality: String = ""
    @Published var subLocality: String = ""
    @Published var thoroughfare: String = ""

    override init() {
        super.init()
        setupLocationManager()
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }

    private func performReverseGeocoding(for location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                self?.resetLocationDetails()
                return
            }

            DispatchQueue.main.async {
                self?.country = placemark.country ?? ""
                self?.administrativeArea = placemark.administrativeArea ?? ""
                self?.subAdministrativeArea = placemark.subAdministrativeArea ?? ""
                self?.locality = placemark.locality ?? ""
                self?.subLocality = placemark.subLocality ?? ""
                self?.thoroughfare = placemark.thoroughfare ?? ""

                var nameParts = [String]()
                if let subLocality = placemark.subLocality, !subLocality.isEmpty {
                    nameParts.append(subLocality)
                }
                if let locality = placemark.locality, !locality.isEmpty {
                    nameParts.append(locality)
                }
                if let subAdministrative = placemark.subAdministrativeArea, !subAdministrative.isEmpty {
                    nameParts.append(subAdministrative)
                }
                if let administrative = placemark.administrativeArea, !administrative.isEmpty {
                    nameParts.append(administrative)
                }
                if let country = placemark.country, !country.isEmpty {
                    nameParts.append(country)
                }

                self?.placeName = nameParts.joined(separator: ", ")
            }
        }
    }

    private func resetLocationDetails() {
        DispatchQueue.main.async {
            self.placeName = "Unknown Location"
            self.country = ""
            self.administrativeArea = ""
            self.subAdministrativeArea = ""
            self.locality = ""
            self.subLocality = ""
            self.thoroughfare = ""
        }
    }
}

extension CompassLocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        DispatchQueue.main.async {
            self.heading = newHeading.magneticHeading
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.altitude = location.altitude
            self.accuracy = location.horizontalAccuracy
            self.coordinates = location.coordinate
            self.performReverseGeocoding(for: location)
        }
    }
}
