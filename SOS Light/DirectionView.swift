//
//  DirectionView.swift
//  SOS Light
//
//  Created by Pieter Yoshua Natanael on 29/04/25.
//


import SwiftUI
import CoreLocation

struct DirectionView: View {
    @StateObject private var locationHandler = LocationHandler()
    @State private var isLocationLocked = false
    @State private var showMap = false // This state controls the visibility of the map
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color(white: 0.08)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 18) {
                if !showMap { // Only show the rest of the UI if map is not visible
                    Text("DIRECTION")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .tracking(2)
                        .foregroundColor(.white)

                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                            .frame(width: 190, height: 190)

                        Image(systemName: "location.north.fill")
                            .resizable()
                            .frame(width: 92, height: 92)
                            .rotationEffect(Angle(degrees: locationHandler.arrowRotation))
                            .foregroundColor(.white)
                            .animation(.easeInOut, value: locationHandler.arrowRotation)
                    }
                    
                    Text("Distance: \(locationHandler.distanceText)")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                    
                    VStack(spacing: 10) {
                        Button(action: {
                            if !isLocationLocked {
                                locationHandler.saveCurrentLocation()
                            }
                        }) {
                            Text(isLocationLocked ? "Location Locked" : "Save My Location")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(12)
                        }
                        .disabled(isLocationLocked)
                        
                        Button(action: {
                            isLocationLocked.toggle()
                        }) {
                            Text(isLocationLocked ? "Unlock Location" : "Lock Location")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.clear)
                                .foregroundColor(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                                )
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            showMap.toggle()
                        }) {
                            Text("Show Map")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.08))
                                .foregroundColor(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.35), lineWidth: 1)
                                )
                                .cornerRadius(12)
                        }
                    }
                    
                    Text("Arrow works offline. It guides you back to the saved location.")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                if showMap {
                    VStack(spacing: 12) {
                        Button(action: {
                            showMap.toggle()
                        }) {
                            Text("Back")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(12)
                        }
                        .padding(.top, 8)
                        
                        MapView()
                            .cornerRadius(12)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            locationHandler.start()
        }
    }
}

#Preview {
    DirectionView()
}


// MARK: - Location + Compass Handler (Integrated in same file)
class LocationHandler: NSObject, ObservableObject, CLLocationManagerDelegate {
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
        return degrees * .pi / 180.0
    }

    private func radiansToDegrees(_ radians: Double) -> Double {
        return radians * 180.0 / .pi
    }
}

#Preview {
    DirectionView()
}
