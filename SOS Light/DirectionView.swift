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
        VStack(spacing: 30) {
            if !showMap { // Only show the rest of the UI if map is not visible
                Spacer()
                
                // Rotating arrow based on compass and saved location
                Image(systemName: "location.north.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .rotationEffect(Angle(degrees: locationHandler.arrowRotation))
                    .foregroundColor(Color(#colorLiteral(red: 0.4500938654, green: 0.9813225865, blue: 0.4743030667, alpha: 1)))
                    .animation(.easeInOut, value: locationHandler.arrowRotation)
                
                // Distance to target
                Text("Distance: \(locationHandler.distanceText)")
                    .font(.headline)
                
                Spacer()
                
                // Save current location button (Disabled when locked)
                Button(action: {
                    if !isLocationLocked {
                        locationHandler.saveCurrentLocation()
                    }
                }) {
                    Text(isLocationLocked ? "Location Locked" : "Save My Location")
                        .padding()
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .background(isLocationLocked ? Color.gray : Color.green)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }
                .disabled(isLocationLocked)
                
                // Lock/Unlock button
                Button(action: {
                    isLocationLocked.toggle()
                }) {
                    Text(isLocationLocked ? "Unlock Location" : "Lock Location")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isLocationLocked ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                // Button to toggle the map visibility
                Button(action: {
                    showMap.toggle()
                }) {
                    Text(showMap ? "Hide Map" : "Show Map")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Text("Arrow works offline. It guides you back to the saved location.")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Show the MapView in full-screen if `showMap` is true
            if showMap {
                VStack {
                    // Back button to return to the previous screen
                    Button(action: {
                        showMap.toggle()
                    }) {
                        Text("Back")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.top)
                    }
                    
                    // MapView itself (replace with your MapView)
                    MapView() // Adjust to your full-screen MapView
                        .edgesIgnoringSafeArea(.all) // Make the map cover the whole screen
                }
            }
        }
        .padding()
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
