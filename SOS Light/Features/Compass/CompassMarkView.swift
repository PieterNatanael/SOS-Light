import SwiftUI

struct CompassMarkView: View {
    let degree: Double

    private var directionText: String {
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
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 1, height: 8)
            } else {
                Text(directionText)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .rotationEffect(Angle(degrees: -degree))

                Rectangle()
                    .fill(Color.primary)
                    .frame(width: 2, height: 12)
            }
        }
        .offset(y: -120)
        .rotationEffect(Angle(degrees: degree))
    }
}
