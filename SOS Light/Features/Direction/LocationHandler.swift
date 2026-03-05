import CoreLocation

final class DirectionLocationHandler: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    private var savedLocation: CLLocationCoordinate2D?
    @Published var arrowRotation: Double = 0.0
    @Published var distanceText: String = "--"

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.headingFilter = 1
        locationManager.requestWhenInUseAuthorization()
    }

    func start() {
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }

    func saveCurrentLocation() {
        if let loc = locationManager.location?.coordinate {
            savedLocation = loc
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        guard let userLoc = locationManager.location?.coordinate,
              let targetLoc = savedLocation else { return }

        let bearingToTarget = getBearing(from: userLoc, to: targetLoc)
        let heading = newHeading.trueHeading
        let angle = bearingToTarget - heading
        arrowRotation = angle
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateDistance()
    }

    private func updateDistance() {
        guard let userLoc = locationManager.location,
              let target = savedLocation else {
            distanceText = "--"
            return
        }

        let distance = userLoc.distance(from: CLLocation(latitude: target.latitude, longitude: target.longitude))
        if distance < 1000 {
            distanceText = String(format: "%.0f meters", distance)
        } else {
            distanceText = String(format: "%.2f km", distance / 1000)
        }
    }

    private func getBearing(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLat = degreesToRadians(from.latitude)
        let fromLon = degreesToRadians(from.longitude)
        let toLat = degreesToRadians(to.latitude)
        let toLon = degreesToRadians(to.longitude)

        let dLon = toLon - fromLon
        let y = sin(dLon) * cos(toLat)
        let x = cos(fromLat) * sin(toLat) - sin(fromLat) * cos(toLat) * cos(dLon)
        let radiansBearing = atan2(y, x)
        return radiansToDegrees(radiansBearing)
    }

    private func degreesToRadians(_ degrees: Double) -> Double {
        degrees * .pi / 180.0
    }

    private func radiansToDegrees(_ radians: Double) -> Double {
        radians * 180.0 / .pi
    }
}
