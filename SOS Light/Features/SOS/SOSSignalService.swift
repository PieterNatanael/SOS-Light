//
//  SOSSignalService.swift
//  SOS Light
//
//  Handles hardware side effects used by SOS broadcasting.
//

import AVFoundation

final class SOSSignalService {
    // Torch control is isolated here so view models only orchestrate state/timing.
    func setFlash(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        try? device.lockForConfiguration()
        device.torchMode = on ? .on : .off
        device.unlockForConfiguration()
    }

    // Always turn the torch off explicitly when SOS stops.
    func turnOffFlash() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        try? device.lockForConfiguration()
        device.torchMode = .off
        device.unlockForConfiguration()
    }

    // Play the existing system sound used by SOS Light.
    func playSound() {
        AudioServicesPlaySystemSound(1033)
    }
}
