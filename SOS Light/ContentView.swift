//
//  ContentView.swift
//  SOS Light
//
//  Created by Pieter Yoshua Natanael on 11/06/24.
//
//SOS Light is designed to maximize the chances of getting help in emergency situations, both indoors and outdoors, for users of all ages. With a simple tap, the app activates your screen and camera flash to blink a Morse code: SOS
//link Apple store :https://apps.apple.com/app/s0s-light/id6504213303

import SwiftUI
import AVFoundation

private enum SOSConstants {
    static let pulseInterval: TimeInterval = 0.5
    static let restartDelay: TimeInterval = 3.0
}

struct ContentView: View {
    @State private var showAdsAndAppFunctionality = false
    @State private var isSOSActive = false
    @State private var flashTimer: Timer?
    @State private var screenColor: Color = .black
    @State private var isSoundOn = false // State for sound toggle
    @State private var pulse = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 28) {
                HStack {
                    Text("SOS LIGHT")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundColor(screenColor == .white ? .black : .white)
                        .tracking(2)
                    Spacer()
                    Button(action: {
                        showAdsAndAppFunctionality = true
                    }) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(screenColor == .white ? .black : .white)
                            .padding(10)
                            .overlay(
                                Circle()
                                    .stroke(screenColor == .white ? Color.black.opacity(0.5) : Color.white.opacity(0.45), lineWidth: 1)
                            )
                    }
                }
                .padding(.top, geometry.safeAreaInsets.top + 8)

                VStack(spacing: 10) {
                    Text(isSOSActive ? "BROADCASTING" : "STANDBY")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .tracking(1.2)
                        .foregroundColor(screenColor == .white ? .black.opacity(0.8) : .white.opacity(0.8))

                    HStack(spacing: 10) {
                        Circle()
                            .fill(screenColor == .white ? Color.black : Color.white)
                            .frame(width: 8, height: 8)
                            .opacity(isSOSActive ? (pulse ? 0.25 : 1.0) : 0.35)

                        Text(isSOSActive ? "SOS ACTIVE" : "SOS INACTIVE")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(screenColor == .white ? .black : .white)
                    }
                }

                ZStack {
                    Circle()
                        .stroke(screenColor == .white ? Color.black.opacity(0.2) : Color.white.opacity(0.2), lineWidth: 1)
                        .frame(width: 240, height: 240)

                    Circle()
                        .stroke(screenColor == .white ? Color.black.opacity(0.35) : Color.white.opacity(0.35), lineWidth: 2)
                        .frame(width: 210, height: 210)
                        .scaleEffect(isSOSActive && pulse ? 1.08 : 1.0)
                        .opacity(isSOSActive ? 1 : 0.5)
                        .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: pulse)

                    Button(action: {
                        isSOSActive.toggle()
                        if isSOSActive {
                            startSOS()
                        } else {
                            stopSOS()
                        }
                    }) {
                        Text(isSOSActive ? "STOP SOS" : "START SOS")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .tracking(1)
                            .frame(width: 170, height: 170)
                            .background(screenColor == .white ? Color.black : Color.white)
                            .foregroundColor(screenColor == .white ? .white : .black)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(screenColor == .white ? Color.black : Color.white, lineWidth: 2)
                            )
                    }
                    .shadow(color: (screenColor == .white ? Color.black : Color.white).opacity(0.15), radius: 12, x: 0, y: 6)
                }

                Text("Tap once to send the SOS signal pattern with flash + screen.")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundColor(screenColor == .white ? .black.opacity(0.7) : .white.opacity(0.7))
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
            .background(screenColor.edgesIgnoringSafeArea(.all))
            .sheet(isPresented: $showAdsAndAppFunctionality) {
                ShowAdsAndAppFunctionalityView(isSoundOn: $isSoundOn, onConfirm: {
                    showAdsAndAppFunctionality = false
                })
            }
            .onAppear {
                pulse = true
            }
        }
    }
    
    // MARK: - SOS Control

    // Keep the existing pulse timing unchanged so the working SOS pattern is preserved.
    func startSOS() {
        let sequence = makeSOSSequence()
        
        var currentIndex = 0
        flashTimer = Timer.scheduledTimer(withTimeInterval: SOSConstants.pulseInterval, repeats: true) { timer in
            if currentIndex < sequence.count {
                let value = sequence[currentIndex]
                toggleFlash(on: value)
                toggleScreen(on: value)
                if value && isSoundOn {
                    playSound()
                }
                currentIndex += 1
            } else {
                timer.invalidate()
                // Restart after a short pause while SOS remains active.
                Timer.scheduledTimer(withTimeInterval: SOSConstants.restartDelay, repeats: false) { _ in
                    if self.isSOSActive {
                        self.startSOS()
                    }
                }
            }
        }
        flashTimer?.fire()
    }

    // Flatten the Morse SOS pattern into a timed sequence of on/off pulses.
    func makeSOSSequence() -> [Bool] {
        let morseDot = [true]
        let morseDash = [true, true, true]
        let morseSOS: [[Bool]] = [morseDot, morseDot, morseDot, morseDash, morseDash, morseDash, morseDot, morseDot, morseDot]
        var sequence = [Bool]()

        for morseSignal in morseSOS {
            sequence.append(contentsOf: morseSignal)
            sequence.append(false)
        }

        return sequence
    }
    
    // Stop any active SOS output and reset the visual state back to idle.
    func stopSOS() {
        flashTimer?.invalidate()
        flashTimer = nil
        turnOffFlash()
        screenColor = .black
    }
    
    // MARK: - Device Output

    // Torch control is isolated here so the broadcast logic only deals with on/off pulses.
    func toggleFlash(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        try? device.lockForConfiguration()
        device.torchMode = on ? .on : .off
        device.unlockForConfiguration()
    }
    
    // The screen flashes by swapping between the two high-contrast background colors.
    func toggleScreen(on: Bool) {
        screenColor = on ? .white : .black
    }
    
    // Always turn the torch off explicitly when SOS stops.
    func turnOffFlash() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        try? device.lockForConfiguration()
        device.torchMode = .off
        device.unlockForConfiguration()
    }
    
    // Play the existing system sound only when the user has enabled it.
    func playSound() {

        AudioServicesPlaySystemSound(1033)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainAppView()
    }
}




