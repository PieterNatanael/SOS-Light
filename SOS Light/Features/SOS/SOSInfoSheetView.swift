//
//  SOSInfoSheetView.swift
//  SOS Light
//
//  Extracted from ContentView for maintainability.
//

import SwiftUI

struct ShowAdsAndAppFunctionalityView: View {
    @Binding var isSoundOn: Bool
    var onConfirm: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color(white: 0.08)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    HStack {
                        Text("SOS INFO")
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .tracking(1.5)
                            .foregroundColor(.white)
                        Spacer()
                    }

                    HStack {
                        Text("SOS Sound")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                        Spacer()
                        Toggle("Sound", isOn: $isSoundOn)
                            .labelsHidden()
                            .toggleStyle(SwitchToggleStyle(tint: .white))
                    }
                    .padding()
                    .background(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
                    .cornerRadius(12)

                    HStack {
                        Text("Apps for You")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                        Spacer()
                    }

                    VStack(spacing: 8) {
                        AppCardView(imageName: "timetell", appName: "TimeTell", appDescription: "Tells the time every 30 seconds — for mindfulness, timeboxing, ADHD focus, workouts, and more", appURL: "https://apps.apple.com/app/time-tell/id6479016269")
                        AppCardView(imageName: "SingLoop", appName: "Sing LOOP", appDescription: "Sing Loop lets you record your voice and play it back in a loop—great for practicing, layering, and enjoying your own voice. Sing, experiment with melodies, and get creative.", appURL: "https://apps.apple.com/id/app/sing-l00p/id6480459464")
                        AppCardView(imageName: "iprogram", appName: "iProgramMe", appDescription: "Custom affirmations.", appURL: "https://apps.apple.com/id/app/iprogramme/id6470770935")
                    }
                    .padding()
                    .background(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
                    .cornerRadius(12)

                    HStack {
                        Text("App Functionality")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                        Spacer()
                    }

                    Text(
"""
   • Press 'Start SOS' to activate the SOS signal.
   • The screen and flash will blink in SOS pattern (three short signals, three long signals, and three short signals again).
   • Press 'Stop SOS' to deactivate the signal and stop the blinking.
  
""")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.86))
                    .multilineTextAlignment(.leading)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
                    .cornerRadius(12)

                    HStack {
                        Text("""
                           Love SOS Light? Open SOS Relax to learn more.
                    """)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.86))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    Button("Close") {
                        onConfirm()
                    }
                    .font(.headline.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(12)
                    .padding(.top, 4)
                }
                .padding()
            }
        }
    }
}

struct AppCardView: View {
    let imageName: String
    let appName: String
    let appDescription: String
    let appURL: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(imageName)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.35), radius: 5)
                VStack(alignment: .leading) {
                    Text(appName)
                        .font(.headline.bold())
                        .foregroundColor(.white)
                    Text(appDescription)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.82))
                }
                Spacer()
            }
            .onTapGesture {
                if let url = URL(string: appURL) {
                    UIApplication.shared.open(url)
                }
            }
        }
        .padding(10)
        .background(Color.white.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(10)
    }
}
