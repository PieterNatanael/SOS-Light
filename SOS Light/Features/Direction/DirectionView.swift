import SwiftUI

struct DirectionView: View {
    @StateObject private var locationHandler = DirectionLocationHandler()
    @State private var isLocationLocked = false
    @State private var showMap = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color(white: 0.08)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 18) {
                if !showMap {
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
