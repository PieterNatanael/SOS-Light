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
