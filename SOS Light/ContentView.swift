//
//  ContentView.swift
//  SOS Light
//
//  Created by Pieter Yoshua Natanael on 11/06/24.
//
//SOS Light is designed to maximize the chances of getting help in emergency situations, both indoors and outdoors, for users of all ages. With a simple tap, the app activates your screen and camera flash to blink a Morse code: SOS
//link Apple store :https://apps.apple.com/app/s0s-light/id6504213303

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SOSViewModel()
    @State private var showAdsAndAppFunctionality = false
    @State private var pulse = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 28) {
                HStack {
                    Text("SOS LIGHT")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundColor(viewModel.screenColor == .white ? .black : .white)
                        .tracking(2)
                    Spacer()
                    Button(action: {
                        showAdsAndAppFunctionality = true
                    }) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(viewModel.screenColor == .white ? .black : .white)
                            .padding(10)
                            .overlay(
                                Circle()
                                    .stroke(viewModel.screenColor == .white ? Color.black.opacity(0.5) : Color.white.opacity(0.45), lineWidth: 1)
                            )
                    }
                }
                .padding(.top, geometry.safeAreaInsets.top + 8)

                VStack(spacing: 10) {
                    Text(viewModel.isSOSActive ? "BROADCASTING" : "STANDBY")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .tracking(1.2)
                        .foregroundColor(viewModel.screenColor == .white ? .black.opacity(0.8) : .white.opacity(0.8))

                    HStack(spacing: 10) {
                        Circle()
                            .fill(viewModel.screenColor == .white ? Color.black : Color.white)
                            .frame(width: 8, height: 8)
                            .opacity(viewModel.isSOSActive ? (pulse ? 0.25 : 1.0) : 0.35)

                        Text(viewModel.isSOSActive ? "SOS ACTIVE" : "SOS INACTIVE")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(viewModel.screenColor == .white ? .black : .white)
                    }
                }

                ZStack {
                    Circle()
                        .stroke(viewModel.screenColor == .white ? Color.black.opacity(0.2) : Color.white.opacity(0.2), lineWidth: 1)
                        .frame(width: 240, height: 240)

                    Circle()
                        .stroke(viewModel.screenColor == .white ? Color.black.opacity(0.35) : Color.white.opacity(0.35), lineWidth: 2)
                        .frame(width: 210, height: 210)
                        .scaleEffect(viewModel.isSOSActive && pulse ? 1.08 : 1.0)
                        .opacity(viewModel.isSOSActive ? 1 : 0.5)
                        .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: pulse)

                    Button(action: {
                        viewModel.toggleSOS()
                    }) {
                        Text(viewModel.isSOSActive ? "STOP SOS" : "START SOS")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .tracking(1)
                            .frame(width: 170, height: 170)
                            .background(viewModel.screenColor == .white ? Color.black : Color.white)
                            .foregroundColor(viewModel.screenColor == .white ? .white : .black)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(viewModel.screenColor == .white ? Color.black : Color.white, lineWidth: 2)
                            )
                    }
                    .shadow(color: (viewModel.screenColor == .white ? Color.black : Color.white).opacity(0.15), radius: 12, x: 0, y: 6)
                }

                Text("Tap once to send the SOS signal pattern with flash + screen.")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundColor(viewModel.screenColor == .white ? .black.opacity(0.7) : .white.opacity(0.7))
                    .padding(.horizontal)
                
                Spacer(minLength: 10)
//                Text("❤️ Love SOS Light? Open SOS Relax to learn more")
//                    .font(.footnote)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal)
//                    .padding()
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 22)
            .background(viewModel.screenColor.edgesIgnoringSafeArea(.all))
            .sheet(isPresented: $showAdsAndAppFunctionality) {
                ShowAdsAndAppFunctionalityView(isSoundOn: $viewModel.isSoundOn, onConfirm: {
                    showAdsAndAppFunctionality = false
                })
            }
            .onAppear {
                pulse = true
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainAppView()
    }
}



