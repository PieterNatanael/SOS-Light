//
//  MapView.swift
//  SOS Light
//
//  Created by Pieter Yoshua Natanael on 29/04/25.
//

import SwiftUI
import MapKit
import CoreLocation

// MARK: - Main Map View

struct MapView: View {
    // Location manager object to track user's GPS location
    @StateObject private var mapManager = MapManager()

    // The region shown on the map
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )

    // Flags to handle user interaction
    @State private var isUserDragging = false
    @State private var showingUserLocation = true

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // The Map itself, showing user's location
            Map(coordinateRegion: $region, showsUserLocation: true)
                .gesture(
                    // When user drags the map, stop auto-centering
                    DragGesture().onChanged { _ in
                        isUserDragging = true
                        showingUserLocation = false
                    }
                )
                .onReceive(mapManager.$lastLocation) { location in
                    // Auto-center the map only if user hasn’t dragged
                    if let location = location, showingUserLocation {
                        region = MKCoordinateRegion(
                            center: location.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                    }
                }
                .edgesIgnoringSafeArea(.top) // extend behind the status bar only

            // "Center on Me" Button
            Button(action: {
                if let location = mapManager.lastLocation {
                    region = MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                    showingUserLocation = true
                    isUserDragging = false
                }
            }) {
                Image(systemName: "location.fill")
                    .padding()
                    .background(Color(#colorLiteral(red: 0.4500938654, green: 0.9813225865, blue: 0.4743030667, alpha: 1)))
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
            .padding(.bottom, 70) // raised above tab bar
            .padding(.trailing, 20)
        }
    }
}

// MARK: - Location Manager Class

class MapManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var lastLocation: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        // Request location permission
        locationManager.requestWhenInUseAuthorization()

        // Start tracking location updates
        locationManager.startUpdatingLocation()
    }

    // Delegate method to receive location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
    }
}

// MARK: - Preview

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
