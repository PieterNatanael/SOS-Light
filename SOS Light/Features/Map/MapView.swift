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
        ZStack(alignment: .top) {
            Map(coordinateRegion: $region, showsUserLocation: true)
                .gesture(
                    DragGesture().onChanged { _ in
                        isUserDragging = true
                        showingUserLocation = false
                    }
                )
                .onReceive(mapManager.$lastLocation) { location in
                    if let location = location, showingUserLocation {
                        region = MKCoordinateRegion(
                            center: location.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                    }
                }
                .overlay(
                    LinearGradient(
                        colors: [Color.black.opacity(0.45), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 130),
                    alignment: .top
                )
                .ignoresSafeArea(edges: .top)

            VStack {
                HStack {
                    Text("MAP")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .tracking(1.5)
                        .foregroundColor(.white)
                    Spacer()
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
                            .font(.headline)
                            .padding(12)
                            .background(Color.white)
                            .foregroundColor(.black)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 3)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                Spacer()
            }
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
