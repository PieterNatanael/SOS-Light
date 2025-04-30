//
//  compassVIew.swift
//  SOS Light
//
//  Created by Pieter Yoshua Natanael on 30/11/24.
//


import SwiftUI
import CoreLocation

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    @Published var heading: Double = 0
    @Published var altitude: Double = 0
    @Published var accuracy: CLLocationAccuracy = 0
    @Published var coordinates: CLLocationCoordinate2D?
    
    // New published properties for location details
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
                // Update location details
                self?.country = placemark.country ?? ""
                self?.administrativeArea = placemark.administrativeArea ?? ""
                self?.subAdministrativeArea = placemark.subAdministrativeArea ?? ""
                self?.locality = placemark.locality ?? ""
                self?.subLocality = placemark.subLocality ?? ""
                self?.thoroughfare = placemark.thoroughfare ?? ""
                
                // Create a formatted place name
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

extension LocationManager: CLLocationManagerDelegate {
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
            
            // Perform reverse geocoding
            self.performReverseGeocoding(for: location)
        }
    }
}


struct CompassView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var isCopied = false
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                // Compass outer circle with gradient stroke
                Circle()
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [.gray.opacity(0.3), .gray.opacity(0.6)]),
                            center: .center
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 250, height: 250)
                    .shadow(color: .black.opacity(0.1), radius: 5)

                // Compass markings (Major and Minor)
                ForEach(0..<360, id: \.self) { degree in
                    if degree % 15 == 0 {
                        CompassMarkView(degree: Double(degree), currentHeading: locationManager.heading)
                    }
                }

                // Highlight current heading with a glowing ring
                Circle()
                    .stroke(Color(#colorLiteral(red: 0.4500938654, green: 0.9813225865, blue: 0.4743030667, alpha: 1)), lineWidth: 3)
                    .frame(width: 260, height: 260)
                    .opacity(locationManager.heading == 0 ? 0.5 : 0.2)  // Adjust opacity for better view
                    .blur(radius: locationManager.heading == 0 ? 5 : 0) // Add subtle glow effect
                    .rotationEffect(Angle(degrees: locationManager.heading))
                    .animation(.easeInOut(duration: 1), value: locationManager.heading)

                // Stylish compass arrow
                ZStack {
//                    Circle()
//                        .fill(Color.white)
//                        .frame(width: 50, height: 50)
//                        .shadow(radius: 2)

                    Image(systemName: "location.north.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(Color(#colorLiteral(red: 0.4500938654, green: 0.9813225865, blue: 0.4743030667, alpha: 1)))
                        .rotationEffect(Angle(degrees: -locationManager.heading))
                }
            }
            .rotationEffect(Angle(degrees: locationManager.heading))

            
            Spacer()
            
            Text("Current Heading: \(Int(locationManager.heading))°")
                .padding()
            
            VStack(alignment: .leading, spacing: 10) {
                // Display place name
                HStack {
                    Image(systemName: "mappin.circle")
                    Text(locationManager.placeName)
                        .fontWeight(.bold)
                }
                
                HStack {
                    Image(systemName: "arrow.up.and.down.circle")
                    Text("Altitude: \(String(format: "%.1f", locationManager.altitude)) m")
                }
                
                // Coordinates Display
                if let coords = locationManager.coordinates {
                    HStack {
                        Image(systemName: "map")
                        Text("Coordinates:")
                        Text(coordinatesString(coords))
                            .fontWeight(.bold)
                    }
                }
                
                HStack {
                    Image(systemName: "location.circle")
                    Text("Accuracy: \(String(format: "%.1f", locationManager.accuracy)) m")
                    .foregroundColor(accuracyColor)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            Spacer()
            // Large Copy Button
            Button(action: {
                copyLocationInformation()
            }) {
                HStack {
                    Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                    Text(isCopied ? "Copied!" : "Copy Location Details")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isCopied ? Color.blue : Color(#colorLiteral(red: 0.4500938654, green: 0.9813225865, blue: 0.4743030667, alpha: 1)))
                .foregroundColor(.black)
                .cornerRadius(10)
                .font(.headline)
            }
            .padding()
        }
    }
    
    // Format coordinates for easy sharing
    func coordinatesString(_ coordinate: CLLocationCoordinate2D) -> String {
        return String(format: "%.6f, %.6f", coordinate.latitude, coordinate.longitude)
    }
    
    // Copy location information
    func copyLocationInformation() {
        guard let coords = locationManager.coordinates else { return }
        
        let locationInfo = """
        Location: \(locationManager.placeName)
        Heading: \(Int(locationManager.heading))°
        Altitude: \(String(format: "%.1f", locationManager.altitude)) m
        Coordinates: \(coordinatesString(coords))
        Accuracy: \(String(format: "%.1f", locationManager.accuracy)) m
        
        Detailed Location:
        Country: \(locationManager.country)
        Administrative Area: \(locationManager.administrativeArea)
        Sub-Administrative Area: \(locationManager.subAdministrativeArea)
        Locality: \(locationManager.locality)
        Sub-Locality: \(locationManager.subLocality)
        Thoroughfare: \(locationManager.thoroughfare)
        """
        
        UIPasteboard.general.string = locationInfo
        isCopied = true
        
        // Reset copied state after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isCopied = false
        }
    }
    
    var accuracyColor: Color {
        switch locationManager.accuracy {
        case ..<0:
            return .red  // Invalid location
        case 0..<10:
            return .green  // Very accurate
        case 10..<50:
            return .yellow  // Moderate accuracy
        default:
            return .red  // Poor accuracy
        }
    }
}
// Compass marking view for cardinal and ordinal directions
struct CompassMarkView: View {
    let degree: Double
    let currentHeading: Double

    var directionText: String {
        switch degree {
        case 0: return "N"
        case 45: return "NE"
        case 90: return "E"
        case 135: return "SE"
        case 180: return "S"
        case 225: return "SW"
        case 270: return "W"
        case 315: return "NW"
        default: return ""
        }
    }

    var body: some View {
        VStack(spacing: 2) {
            if directionText.isEmpty {
                // Minor tick
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 1, height: 8)
            } else {
                // Major mark
                Text(directionText)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .rotationEffect(Angle(degrees: -degree)) // Keep upright

                Rectangle()
                    .fill(Color.primary)
                    .frame(width: 2, height: 12)
            }
        }
        .offset(y: -120)
        .rotationEffect(Angle(degrees: degree))
    }
}


struct CompassView_Previews: PreviewProvider {
    static var previews: some View {
        CompassView()
    }
}



/*
//works but mau ada improvement agar kalau di copy semua informasi sekalian di copy
import SwiftUI
import CoreLocation

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    @Published var heading: Double = 0
    @Published var altitude: Double = 0
    @Published var accuracy: CLLocationAccuracy = 0
    @Published var coordinates: CLLocationCoordinate2D?
    
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
}

extension LocationManager: CLLocationManagerDelegate {
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
        }
    }
}


struct CompassView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var isCopied = false
    
    var body: some View {
        VStack {
            ZStack {
                // Compass background circle
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    .frame(width: 250, height: 250)
                
                // Compass Rose
                Image(systemName: "arrow.up")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.red)
                    .rotationEffect(Angle(degrees: -locationManager.heading))
                
                // Compass markings
                ForEach(0..<360, id: \.self) { degree in
                    if degree % 45 == 0 {
                        CompassMarkView(degree: Double(degree), currentHeading: locationManager.heading)
                    }
                }
            }
            .rotationEffect(Angle(degrees: locationManager.heading))
            
            Text("Current Heading: \(Int(locationManager.heading))°")
                .padding()
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "arrow.up.and.down.circle")
                    Text("Altitude: \(String(format: "%.1f", locationManager.altitude)) m")
                }
                
                
            
                    
                    // Coordinates Display with Copy Button
                    if let coords = locationManager.coordinates {
                        HStack {
                            Image(systemName: "map")
                            Text("Coordinates:")
                            Text(coordinatesString(coords))
                                .fontWeight(.bold)
                            
                            Button(action: {
                                UIPasteboard.general.string = coordinatesString(coords)
                                isCopied = true
                                
                                // Reset copied state after 2 seconds
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    isCopied = false
                                }
                            }) {
                                Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                                    .foregroundColor(isCopied ? .green : .blue)
                            }
                        }
                    
                    
                }
                
                HStack {
                    Image(systemName: "location.circle")
                    Text("Accuracy: \(String(format: "%.1f", locationManager.accuracy)) m")
                    .foregroundColor(accuracyColor)}
                
                
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
    
    // Format coordinates for easy sharing
       func coordinatesString(_ coordinate: CLLocationCoordinate2D) -> String {
           return String(format: "%.6f, %.6f", coordinate.latitude, coordinate.longitude)
       }
    
    var accuracyColor: Color {
        switch locationManager.accuracy {
        case ..<0:
            return .red  // Invalid location
        case 0..<10:
            return .green  // Very accurate
        case 10..<50:
            return .yellow  // Moderate accuracy
        default:
            return .red  // Poor accuracy
        }
    }
}
// Compass marking view for cardinal and ordinal directions
struct CompassMarkView: View {
    let degree: Double
    let currentHeading: Double
    
    var directionText: String {
        switch degree {
        case 0: return "N"
        case 45: return "NE"
        case 90: return "E"
        case 135: return "SE"
        case 180: return "S"
        case 225: return "SW"
        case 270: return "W"
        case 315: return "NW"
        default: return ""
        }
    }
    
    var body: some View {
        VStack {
            Text(directionText)
                .font(.caption)
                .rotationEffect(Angle(degrees: -degree + currentHeading))
        }
        .offset(y: -125)
        .rotationEffect(Angle(degrees: degree))
    }
}

*/

/*
//it works but want to add coordinate
import SwiftUI
import CoreLocation

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    @Published var heading: Double = 0
    @Published var altitude: Double = 0
    @Published var accuracy: CLLocationAccuracy = 0
    
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
}

extension LocationManager: CLLocationManagerDelegate {
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
        }
    }
}

struct CompassView: View {
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        VStack {
            ZStack {
                // Compass background circle
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    .frame(width: 250, height: 250)
                
                // Compass Rose
                Image(systemName: "arrow.up")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.red)
                    .rotationEffect(Angle(degrees: -locationManager.heading))
                
                // Compass markings
                ForEach(0..<360, id: \.self) { degree in
                    if degree % 45 == 0 {
                        CompassMarkView(degree: Double(degree), currentHeading: locationManager.heading)
                    }
                }
            }
            .rotationEffect(Angle(degrees: locationManager.heading))
            
            Text("Current Heading: \(Int(locationManager.heading))°")
                .padding()
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "arrow.up.and.down.circle")
                    Text("Altitude: \(String(format: "%.1f", locationManager.altitude)) m")
                }
                
                
                HStack {
                    Image(systemName: "location.circle")
                    Text("Accuracy: \(String(format: "%.1f", locationManager.accuracy)) m")
                        .foregroundColor(accuracyColor)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
    
    
    var accuracyColor: Color {
        switch locationManager.accuracy {
        case ..<0:
            return .red  // Invalid location
        case 0..<10:
            return .green  // Very accurate
        case 10..<50:
            return .yellow  // Moderate accuracy
        default:
            return .red  // Poor accuracy
        }
    }
}
// Compass marking view for cardinal and ordinal directions
struct CompassMarkView: View {
    let degree: Double
    let currentHeading: Double
    
    var directionText: String {
        switch degree {
        case 0: return "N"
        case 45: return "NE"
        case 90: return "E"
        case 135: return "SE"
        case 180: return "S"
        case 225: return "SW"
        case 270: return "W"
        case 315: return "NW"
        default: return ""
        }
    }
    
    var body: some View {
        VStack {
            Text(directionText)
                .font(.caption)
                .rotationEffect(Angle(degrees: -degree + currentHeading))
        }
        .offset(y: -125)
        .rotationEffect(Angle(degrees: degree))
    }
}

*/

/*
//great but want to add altitude
import SwiftUI
import CoreLocation

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    @Published var heading: Double = 0
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        DispatchQueue.main.async {
            self.heading = newHeading.magneticHeading
        }
    }
    
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
}

struct CompassView: View {
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        VStack {
            ZStack {
                // Compass background circle
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    .frame(width: 250, height: 250)
                
                // Compass Rose
                Image(systemName: "arrow.up")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.red)
                    .rotationEffect(Angle(degrees: -locationManager.heading))
                
                // Compass markings
                ForEach(0..<360, id: \.self) { degree in
                    if degree % 45 == 0 {
                        CompassMarkView(degree: Double(degree), currentHeading: locationManager.heading)
                    }
                }
            }
            .rotationEffect(Angle(degrees: locationManager.heading))
            
            Text("Current Heading: \(Int(locationManager.heading))°")
                .padding()
        }
    }
}

// Compass marking view for cardinal and ordinal directions
struct CompassMarkView: View {
    let degree: Double
    let currentHeading: Double
    
    var directionText: String {
        switch degree {
        case 0: return "N"
        case 45: return "NE"
        case 90: return "E"
        case 135: return "SE"
        case 180: return "S"
        case 225: return "SW"
        case 270: return "W"
        case 315: return "NW"
        default: return ""
        }
    }
    
    var body: some View {
        VStack {
            Text(directionText)
                .font(.caption)
                .rotationEffect(Angle(degrees: -degree + currentHeading))
        }
        .offset(y: -125)
        .rotationEffect(Angle(degrees: degree))
    }
}

*/
