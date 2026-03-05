import SwiftUI
import CoreLocation

struct CompassView: View {
    @StateObject private var locationManager = CompassLocationManager()
    @State private var isCopied = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color(white: 0.08)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    Text("COMPASS")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .tracking(2)
                        .foregroundColor(.white)

                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                            .frame(width: 250, height: 250)

                        ForEach(0..<360, id: \.self) { degree in
                            if degree % 15 == 0 {
                                CompassMarkView(degree: Double(degree))
                            }
                        }

                        Circle()
                            .stroke(Color.white.opacity(0.45), lineWidth: 2)
                            .frame(width: 260, height: 260)
                            .rotationEffect(Angle(degrees: locationManager.heading))
                            .animation(.easeInOut(duration: 1), value: locationManager.heading)

                        Image(systemName: "location.north.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .foregroundColor(.white)
                            .rotationEffect(Angle(degrees: -locationManager.heading))
                    }
                    .rotationEffect(Angle(degrees: locationManager.heading))

                    Text("Current Heading: \(Int(locationManager.heading))°")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "mappin.circle")
                            Text(locationManager.placeName)
                                .fontWeight(.bold)
                        }

                        HStack {
                            Image(systemName: "arrow.up.and.down.circle")
                            Text("Altitude: \(String(format: "%.1f", locationManager.altitude)) m")
                        }

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
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
                    .cornerRadius(12)

                    Button(action: {
                        copyLocationInformation()
                    }) {
                        HStack {
                            Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                            Text(isCopied ? "Copied!" : "Copy Location Details")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical)
            }
        }
    }

    private func coordinatesString(_ coordinate: CLLocationCoordinate2D) -> String {
        String(format: "%.6f, %.6f", coordinate.latitude, coordinate.longitude)
    }

    private func copyLocationInformation() {
        guard let coords = locationManager.coordinates else { return }
        let timestampFormatter = DateFormatter()
        timestampFormatter.dateStyle = .medium
        timestampFormatter.timeStyle = .medium
        let timestamp = timestampFormatter.string(from: Date())

        let locationInfo = """
        Date & Time: \(timestamp)
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isCopied = false
        }
    }

    private var accuracyColor: Color {
        switch locationManager.accuracy {
        case ..<0:
            return .white.opacity(0.55)
        case 0..<10:
            return .white
        case 10..<50:
            return .white.opacity(0.8)
        default:
            return .white.opacity(0.55)
        }
    }
}

struct CompassView_Previews: PreviewProvider {
    static var previews: some View {
        CompassView()
    }
}
