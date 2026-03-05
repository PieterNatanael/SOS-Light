//
//  SOSViewModel.swift
//  SOS Light
//
//  Extracted from ContentView for maintainability.
//

import SwiftUI

private enum SOSConstants {
    static let pulseInterval: TimeInterval = 0.5
    static let restartDelay: TimeInterval = 3.0
}

@MainActor
final class SOSViewModel: ObservableObject {
    @Published var isSOSActive = false
    @Published var screenColor: Color = .black
    @Published var isSoundOn = false

    private var flashTimer: Timer?
    private let signalService: SOSSignalService

    init(signalService: SOSSignalService = SOSSignalService()) {
        self.signalService = signalService
    }

    func toggleSOS() {
        isSOSActive.toggle()
        if isSOSActive {
            startSOS()
        } else {
            stopSOS()
        }
    }

    // Keep the existing pulse timing unchanged so the working SOS pattern is preserved.
    func startSOS() {
        let sequence = makeSOSSequence()
        var currentIndex = 0

        flashTimer = Timer.scheduledTimer(withTimeInterval: SOSConstants.pulseInterval, repeats: true) { [weak self] timer in
            guard let self else { return }

            if currentIndex < sequence.count {
                let value = sequence[currentIndex]
                self.signalService.setFlash(on: value)
                self.toggleScreen(on: value)
                if value && self.isSoundOn {
                    self.signalService.playSound()
                }
                currentIndex += 1
            } else {
                timer.invalidate()
                // Restart after a short pause while SOS remains active.
                Timer.scheduledTimer(withTimeInterval: SOSConstants.restartDelay, repeats: false) { [weak self] _ in
                    guard let self else { return }
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
        signalService.turnOffFlash()
        screenColor = .black
    }

    // The screen flashes by swapping between the two high-contrast background colors.
    func toggleScreen(on: Bool) {
        screenColor = on ? .white : .black
    }
}
