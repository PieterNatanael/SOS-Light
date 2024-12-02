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

struct ContentView: View {
    @State private var showAdsAndAppFunctionality = false
    @State private var isSOSActive = false
    @State private var flashTimer: Timer?
    @State private var screenColor: Color = .black
    @State private var isSoundOn = false // State for sound toggle
    
    let morseDot: [Bool] = [true]
    let morseDash: [Bool] = [true, true, true]
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        showAdsAndAppFunctionality = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color(.white))
                            .padding()
                            .shadow(color: Color.black.opacity(0.6), radius: 5, x: 0, y: 2)
                    }
                }
                Text("SOS Light")
                    .font(.largeTitle)
                    .padding()
                
                Spacer()
                
    
                
                if isSOSActive {
                    Text("SOS Active")
                        .font(.title)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    Text("SOS Inactive")
                        .font(.title)
                        .foregroundColor(.gray)
                        .padding()
                }
                
                Spacer()
                
                Button(action: {
                    isSOSActive.toggle()
                    if isSOSActive {
                        startSOS()
                    } else {
                        stopSOS()
                    }
                }) {
                    Text(isSOSActive ? "Stop SOS" : "Start SOS")
                        .font(.title)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isSOSActive ? Color.red : Color(#colorLiteral(red: 0.4500938654, green: 0.9813225865, blue: 0.4743030667, alpha: 1)))
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }
                .padding()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(screenColor.edgesIgnoringSafeArea(.all))
            .sheet(isPresented: $showAdsAndAppFunctionality) {
                ShowAdsAndAppFunctionalityView(isSoundOn: $isSoundOn, onConfirm: {
                    showAdsAndAppFunctionality = false
                })
            }
        }
    }
    


    
    func startSOS() {
        let morseSOS: [[Bool]] = [morseDot, morseDot, morseDot, morseDash, morseDash, morseDash, morseDot, morseDot, morseDot]
        var sequence = [Bool]()
        for morseSignal in morseSOS {
            sequence.append(contentsOf: morseSignal)
            sequence.append(false)
        }
        
        var currentIndex = 0
        flashTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
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
                Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                    if self.isSOSActive {
                        self.startSOS()
                    }
                }
            }
        }
        flashTimer?.fire()
    }
    
    func stopSOS() {
        flashTimer?.invalidate()
        flashTimer = nil
        turnOffFlash()
        screenColor = .black
    }
    
    func toggleFlash(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        try? device.lockForConfiguration()
        device.torchMode = on ? .on : .off
        device.unlockForConfiguration()
    }
    
    func toggleScreen(on: Bool) {
        screenColor = on ? .white : .black
    }
    
    func turnOffFlash() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        try? device.lockForConfiguration()
        device.torchMode = .off
        device.unlockForConfiguration()
    }
    
    func playSound() {

        AudioServicesPlaySystemSound(1033)
    }
}

struct ShowAdsAndAppFunctionalityView: View {
    @Binding var isSoundOn: Bool
    var onConfirm: () -> Void

    var body: some View {
        ScrollView {
            VStack {
                
                // Sound toggle inside the question mark sheet
                HStack {
                    Text("SOS Sound")
                        .font(.title.bold())
                    Spacer()
                    Toggle("Sound", isOn: $isSoundOn)
                        .labelsHidden()
                }
                .padding()
                HStack {
                    Text("Ads & App Functionality")
                        .font(.title2.bold())
                    Spacer()
                }
                Divider().background(Color.gray)
                
                VStack {
                    HStack {
                        Text("Apps for you")
                            .font(.title.bold())
                        Spacer()
                    }
//                    ZStack {
//                        Image("threedollar")
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .cornerRadius(25)
//                            .clipped()
//                            .onTapGesture {
//                                if let url = URL(string: "https://b33.biz/three-dollar/") {
//                                    UIApplication.shared.open(url)
//                                }
//                            }
//                    }
                    VStack {
//                        Divider().background(Color.gray)
//                        AppCardView(imageName: "loopspeak", appName: "LOOPSpeak", appDescription: "Why read when you can learn by listening? Easily adjust the playback speed.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
//                        
//                        Divider().background(Color.gray)
//                        AppCardView(imageName: "BST", appName: "Blink Screen Time", appDescription: "Blink reminder for eye care: Extended screen time can reduce blinking, leading to dry eyes and fatigue.", appURL: "https://apps.apple.com/id/app/blink-screen-time/id6587551095")
//                        
                        Divider().background(Color.gray)
                        AppCardView(imageName: "bodycam", appName: "BODYCam", appDescription: "Record long videos effortlessly.", appURL: "https://apps.apple.com/id/app/b0dycam/id6496689003")
//                        Divider().background(Color.gray)
//                        AppCardView(imageName: "timetell", appName: "TimeTell", appDescription: "Tell the time every 30 seconds: Just listen, no more guessing or checking your devices", appURL: "https://apps.apple.com/app/time-tell/id6479016269")
                        Divider().background(Color.gray)
                        AppCardView(imageName: "SingLoop", appName: "Sing LOOP", appDescription: "Record and play it back in a loop.", appURL: "https://apps.apple.com/id/app/sing-l00p/id6480459464")
                       
                        Divider().background(Color.gray)
//                        AppCardView(imageName: "insomnia", appName: "Insomnia Sheep", appDescription: "Ease your mind and help you relax leading up to sleep.", appURL: "https://apps.apple.com/id/app/insomnia-sheep/id6479727431")
//                        Divider().background(Color.gray)
//                        AppCardView(imageName: "dryeye", appName: "Dry Eye Read", appDescription: "Adjusting font size and color to suit your reading experience.", appURL: "https://apps.apple.com/id/app/dry-eye-read/id6474282023")
                        Divider().background(Color.gray)
                        AppCardView(imageName: "iprogram", appName: "iProgramMe", appDescription: "Custom affirmations.", appURL: "https://apps.apple.com/id/app/iprogramme/id6470770935")
                        Divider().background(Color.gray)
                 
                      
                    }
                    Spacer()
                }
                .padding()
                .cornerRadius(15.0)

              

                HStack {
                    Text("App Functionality")
                        .font(.title.bold())
                    Spacer()
                }

                Text(
"""
   • Press 'Start SOS' to activate the SOS signal.
   • The screen and flash will blink in SOS pattern (three short signals, three long signals, and three short signals again).
   • Press 'Stop SOS' to deactivate the signal and stop the blinking.
""")
                .font(.title2)
                .multilineTextAlignment(.leading)
                .padding()

                Spacer()

                HStack {
                    Text("SOS Light is developed by Three Dollar.")
                        .font(.title3.bold())
                    Spacer()
                }

                Button("Close") {
                    onConfirm()
                }
                .font(.title)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.vertical, 10)
            }
            .padding()
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
                    .shadow(radius: 5)
                VStack(alignment: .leading) {
                    Text(appName)
                        .font(.title.bold())
                    Text(appDescription)
                        .font(.title2)
                        
                }
                Spacer()
            }
            .onTapGesture {
                if let url = URL(string: appURL) {
                    UIApplication.shared.open(url)
                }
            }
        }
        .padding(.vertical, 5)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainAppView()
    }
}






/*
//owrking well and publised but want to improve
import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var showAdsAndAppFunctionality = false
    @State private var isSOSActive = false
    @State private var flashTimer: Timer?
    @State private var screenColor: Color = .black
    @State private var isSoundOn = false // State for sound toggle
    
    let morseDot: [Bool] = [true]
    let morseDash: [Bool] = [true, true, true]
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        showAdsAndAppFunctionality = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color(.white))
                            .padding()
                            .shadow(color: Color.black.opacity(0.6), radius: 5, x: 0, y: 2)
                    }
                }
                Text("SOS Light")
                    .font(.largeTitle)
                    .padding()
                
                Spacer()
                
                if isSOSActive {
                    Text("SOS Active")
                        .font(.title)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    Text("SOS Inactive")
                        .font(.title)
                        .foregroundColor(.gray)
                        .padding()
                }
                
                Spacer()
                
                Button(action: {
                    isSOSActive.toggle()
                    if isSOSActive {
                        startSOS()
                    } else {
                        stopSOS()
                    }
                }) {
                    Text(isSOSActive ? "Stop SOS" : "Start SOS")
                        .font(.title)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isSOSActive ? Color.red : Color(#colorLiteral(red: 0.4508578777, green: 0.9882974029, blue: 0.8376303315, alpha: 1)))
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }
                .padding()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(screenColor.edgesIgnoringSafeArea(.all))
            .sheet(isPresented: $showAdsAndAppFunctionality) {
                ShowAdsAndAppFunctionalityView(isSoundOn: $isSoundOn, onConfirm: {
                    showAdsAndAppFunctionality = false
                })
            }
        }
    }
    


    
    func startSOS() {
        let morseSOS: [[Bool]] = [morseDot, morseDot, morseDot, morseDash, morseDash, morseDash, morseDot, morseDot, morseDot]
        var sequence = [Bool]()
        for morseSignal in morseSOS {
            sequence.append(contentsOf: morseSignal)
            sequence.append(false)
        }
        
        var currentIndex = 0
        flashTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
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
                Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                    if self.isSOSActive {
                        self.startSOS()
                    }
                }
            }
        }
        flashTimer?.fire()
    }
    
    func stopSOS() {
        flashTimer?.invalidate()
        flashTimer = nil
        turnOffFlash()
        screenColor = .black
    }
    
    func toggleFlash(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        try? device.lockForConfiguration()
        device.torchMode = on ? .on : .off
        device.unlockForConfiguration()
    }
    
    func toggleScreen(on: Bool) {
        screenColor = on ? .white : .black
    }
    
    func turnOffFlash() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        try? device.lockForConfiguration()
        device.torchMode = .off
        device.unlockForConfiguration()
    }
    
    func playSound() {
//        AudioServicesPlaySystemSound(1052)
//        AudioServicesPlaySystemSound(1033)
//        AudioServicesPlaySystemSound(1304)
//        AudioServicesPlaySystemSound(1309)
//        AudioServicesPlaySystemSound(1314)
        AudioServicesPlaySystemSound(1033)
    }
}

struct ShowAdsAndAppFunctionalityView: View {
    @Binding var isSoundOn: Bool
    var onConfirm: () -> Void

    var body: some View {
        ScrollView {
            VStack {
                
                // Sound toggle inside the question mark sheet
                HStack {
                    Text("SOS Sound")
                        .font(.title.bold())
                    Spacer()
                    Toggle("Sound", isOn: $isSoundOn)
                        .labelsHidden()
                }
                .padding()
                HStack {
                    Text("Ads & App Functionality")
                        .font(.title2.bold())
                    Spacer()
                }
                Divider().background(Color.gray)
                
                VStack {
                    HStack {
                        Text("Apps for you")
                            .font(.title.bold())
                        Spacer()
                    }
//                    ZStack {
//                        Image("threedollar")
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .cornerRadius(25)
//                            .clipped()
//                            .onTapGesture {
//                                if let url = URL(string: "https://b33.biz/three-dollar/") {
//                                    UIApplication.shared.open(url)
//                                }
//                            }
//                    }
                    VStack {
                        
                        Divider().background(Color.gray)
                        AppCardView(imageName: "loopspeak", appName: "LOOPSpeak", appDescription: "Why read when you can learn by listening? Easily adjust the playback speed.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
                        
                        Divider().background(Color.gray)
                        AppCardView(imageName: "BST", appName: "Blink Screen Time", appDescription: "Blink reminder for eye care: Extended screen time can reduce blinking, leading to dry eyes and fatigue.", appURL: "https://apps.apple.com/id/app/blink-screen-time/id6587551095")
                        
                        Divider().background(Color.gray)
                        AppCardView(imageName: "bodycam", appName: "BODYCam", appDescription: "Record long videos easily, adjust video quality easily, and reduce file size.", appURL: "https://apps.apple.com/id/app/b0dycam/id6496689003")
                        Divider().background(Color.gray)
                        AppCardView(imageName: "timetell", appName: "TimeTell", appDescription: "Tell the time every 30 seconds: Just listen, no more guessing or checking your devices", appURL: "https://apps.apple.com/app/time-tell/id6479016269")
                        Divider().background(Color.gray)
                        AppCardView(imageName: "SingLoop", appName: "Sing LOOP", appDescription: "Record and play it back in a loop.", appURL: "https://apps.apple.com/id/app/sing-l00p/id6480459464")
                       
                        Divider().background(Color.gray)
                        AppCardView(imageName: "insomnia", appName: "Insomnia Sheep", appDescription: "Ease your mind and help you relax leading up to sleep.", appURL: "https://apps.apple.com/id/app/insomnia-sheep/id6479727431")
                        Divider().background(Color.gray)
                        AppCardView(imageName: "dryeye", appName: "Dry Eye Read", appDescription: "Adjusting font size and color to suit your reading experience.", appURL: "https://apps.apple.com/id/app/dry-eye-read/id6474282023")
                        Divider().background(Color.gray)
                        AppCardView(imageName: "iprogram", appName: "iProgramMe", appDescription: "Custom affirmations.", appURL: "https://apps.apple.com/id/app/iprogramme/id6470770935")
                        Divider().background(Color.gray)
                      
                    }
                    Spacer()
                }
                .padding()
                .cornerRadius(15.0)

              

                HStack {
                    Text("App Functionality")
                        .font(.title.bold())
                    Spacer()
                }

                Text("""
                • Press 'Start SOS' to activate the SOS signal.
                • The screen and flash will blink in SOS pattern (three short signals, three long signals, and three short signals again).
                • Press 'Stop SOS' to deactivate the signal and stop the blinking.
                • In SOS sound mode, adjust the haptic settings to 'Never Play' to disable vibration.
                """)
                .font(.title2)
                .multilineTextAlignment(.leading)
                .padding()

                Spacer()

//                HStack {
//                    Text("SOS Light is developed by Three Dollar.")
//                        .font(.title3.bold())
//                    Spacer()
//                }

                Button("Close") {
                    onConfirm()
                }
                .font(.title)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.vertical, 10)
            }
            .padding()
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
                    .shadow(radius: 5)
                VStack(alignment: .leading) {
                    Text(appName)
                        .font(.title.bold())
                    Text(appDescription)
                        .font(.title2)
                        
                }
                Spacer()
            }
            .onTapGesture {
                if let url = URL(string: appURL) {
                    UIApplication.shared.open(url)
                }
            }
        }
        .padding(.vertical, 5)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
*/
/*
//nagus tapi mau perbaiki sound agar tidak 3 beep tapi 1 beep panjang
import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var showAdsAndAppFunctionality = false
    @State private var isSOSActive = false
    @State private var flashTimer: Timer?
    @State private var screenColor: Color = .black
    @State private var isSoundOn = false // State for sound toggle
    
    let morseDot: [Bool] = [true]
    let morseDash: [Bool] = [true, true, true]
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        showAdsAndAppFunctionality = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color(.white))
                            .padding()
                            .shadow(color: Color.black.opacity(0.6), radius: 5, x: 0, y: 2)
                    }
                }
                Text("SOS Light")
                    .font(.largeTitle)
                    .padding()
                
                Spacer()
                
                if isSOSActive {
                    Text("SOS Active")
                        .font(.title)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    Text("SOS Inactive")
                        .font(.title)
                        .foregroundColor(.gray)
                        .padding()
                }
                
                Spacer()
                
                Button(action: {
                    isSOSActive.toggle()
                    if isSOSActive {
                        startSOS()
                    } else {
                        stopSOS()
                    }
                }) {
                    Text(isSOSActive ? "Stop SOS" : "Start SOS")
                        .font(.title)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isSOSActive ? Color.red : Color(#colorLiteral(red: 0.4508578777, green: 0.9882974029, blue: 0.8376303315, alpha: 1)))
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }
                .padding()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(screenColor.edgesIgnoringSafeArea(.all))
            .sheet(isPresented: $showAdsAndAppFunctionality) {
                ShowAdsAndAppFunctionalityView(isSoundOn: $isSoundOn, onConfirm: {
                    showAdsAndAppFunctionality = false
                })
            }
        }
    }
    
    func startSOS() {
        let morseSOS: [[Bool]] = [morseDot, morseDot, morseDot, morseDash, morseDash, morseDash, morseDot, morseDot, morseDot]
        var sequence = [Bool]()
        for morseSignal in morseSOS {
            sequence.append(contentsOf: morseSignal)
            sequence.append(false)
        }
        
        var currentIndex = 0
        flashTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
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
                Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                    if self.isSOSActive {
                        self.startSOS()
                    }
                }
            }
        }
        flashTimer?.fire()
    }
    
    func stopSOS() {
        flashTimer?.invalidate()
        flashTimer = nil
        turnOffFlash()
        screenColor = .black
    }
    
    func toggleFlash(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        try? device.lockForConfiguration()
        device.torchMode = on ? .on : .off
        device.unlockForConfiguration()
    }
    
    func toggleScreen(on: Bool) {
        screenColor = on ? .white : .black
    }
    
    func turnOffFlash() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        try? device.lockForConfiguration()
        device.torchMode = .off
        device.unlockForConfiguration()
    }
    
    func playSound() {
        AudioServicesPlaySystemSound(1052)
    }
}

struct ShowAdsAndAppFunctionalityView: View {
    @Binding var isSoundOn: Bool
    var onConfirm: () -> Void

    var body: some View {
        ScrollView {
            VStack {
                
                // Sound toggle inside the question mark sheet
                HStack {
                    Text("SOS Sound")
                        .font(.title.bold())
                    Spacer()
                    Toggle("Sound", isOn: $isSoundOn)
                        .labelsHidden()
                }
                .padding()
                HStack {
                    Text("Ads & App Functionality")
                        .font(.title3.bold())
                    Spacer()
                }
                Divider().background(Color.gray)
                
                VStack {
                    HStack {
                        Text("Ads")
                            .font(.largeTitle.bold())
                        Spacer()
                    }
//                    ZStack {
//                        Image("threedollar")
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .cornerRadius(25)
//                            .clipped()
//                            .onTapGesture {
//                                if let url = URL(string: "https://b33.biz/three-dollar/") {
//                                    UIApplication.shared.open(url)
//                                }
//                            }
//                    }
                    VStack {
                        
                        Divider().background(Color.gray)
                        AppCardView(imageName: "loopspeak", appName: "LOOPSpeak", appDescription: "Why read when you can learn by listening? Easily adjust the playback speed.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
                        
                        Divider().background(Color.gray)
                        AppCardView(imageName: "BST", appName: "Blink Screen Time", appDescription: "Blink reminder for eye care: Extended screen time can reduce blinking, leading to dry eyes and fatigue.", appURL: "https://apps.apple.com/id/app/blink-screen-time/id6587551095")
                        
                        Divider().background(Color.gray)
                        AppCardView(imageName: "bodycam", appName: "BODYCam", appDescription: "Record long videos effortlessly.", appURL: "https://apps.apple.com/id/app/b0dycam/id6496689003")
                        Divider().background(Color.gray)
                        AppCardView(imageName: "timetell", appName: "TimeTell", appDescription: "Tell the time every 30 seconds: Just listen, no more guessing or checking your devices", appURL: "https://apps.apple.com/app/time-tell/id6479016269")
                        Divider().background(Color.gray)
                        AppCardView(imageName: "SingLoop", appName: "Sing LOOP", appDescription: "Record and play it back in a loop.", appURL: "https://apps.apple.com/id/app/sing-l00p/id6480459464")
                       
                        Divider().background(Color.gray)
                        AppCardView(imageName: "insomnia", appName: "Insomnia Sheep", appDescription: "Ease your mind and help you relax leading up to sleep.", appURL: "https://apps.apple.com/id/app/insomnia-sheep/id6479727431")
                        Divider().background(Color.gray)
                        AppCardView(imageName: "dryeye", appName: "Dry Eye Read", appDescription: "Adjusting font size and color to suit your reading experience.", appURL: "https://apps.apple.com/id/app/dry-eye-read/id6474282023")
                        Divider().background(Color.gray)
                        AppCardView(imageName: "iprogram", appName: "iProgramMe", appDescription: "Custom affirmations.", appURL: "https://apps.apple.com/id/app/iprogramme/id6470770935")
                        Divider().background(Color.gray)
                      
                    }
                    Spacer()
                }
                .padding()
                .cornerRadius(15.0)

              

                HStack {
                    Text("App Functionality")
                        .font(.title.bold())
                    Spacer()
                }

                Text("""
                • Press 'Start SOS' to activate the SOS signal.
                • The screen and flash will blink in SOS pattern (three short signals, three long signals, and three short signals again).
                • Press 'Stop SOS' to deactivate the signal and stop the blinking.
                """)
                .font(.title3)
                .multilineTextAlignment(.leading)
                .padding()

                Spacer()

//                HStack {
//                    Text("SOS Light is developed by Three Dollar.")
//                        .font(.title3.bold())
//                    Spacer()
//                }

                Button("Close") {
                    onConfirm()
                }
                .font(.title)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.vertical, 10)
            }
            .padding()
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
                    .shadow(radius: 5)
                VStack(alignment: .leading) {
                    Text(appName)
                        .font(.headline)
                    Text(appDescription)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                Spacer()
            }
            .onTapGesture {
                if let url = URL(string: appURL) {
                    UIApplication.shared.open(url)
                }
            }
        }
        .padding(.vertical, 5)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
*/



/*
//bagus dan launched, mau ada tamabahn sound

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var showAdsAndAppFunctionality = false
    @State private var isSOSActive = false
    @State private var flashTimer: Timer?
    @State private var screenColor: Color = .black
    
    // Define Morse code patterns
    let morseDot: [Bool] = [true] // Dot in Morse code
    let morseDash: [Bool] = [true, true, true] // Dash in Morse code
    
    var body: some View {
        GeometryReader { geometry in
            
            VStack {
                
                HStack {
                    Spacer()
                    Button(action: {
                        showAdsAndAppFunctionality = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color(.white))
                            .padding()
                            .shadow(color: Color.black.opacity(0.6), radius: 5, x: 0, y: 2)
                    }
                }

                
                Text("SOS Light")
                    .font(.largeTitle)
                    .padding()
                
                Spacer()
                
                if isSOSActive {
                    Text("SOS Active")
                        .font(.title)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    Text("SOS Inactive")
                        .font(.title)
                        .foregroundColor(.gray)
                        .padding()
                }
                
                Spacer()
                
                Button(action: {
                    isSOSActive.toggle()
                    if isSOSActive {
                        startSOS()
                    } else {
                        stopSOS()
                    }
                }) {
                    Text(isSOSActive ? "Stop SOS" : "Start SOS")
                        .font(.title)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isSOSActive ? Color.red : Color(#colorLiteral(red: 0.4508578777, green: 0.9882974029, blue: 0.8376303315, alpha: 1)))
                        .foregroundColor(.black)
//                        .shadow(color: Color.black.opacity(0.5), radius: 5, x: 0, y: 2)
                        .cornerRadius(10)
                }
                .padding()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(screenColor.edgesIgnoringSafeArea(.all))
            .sheet(isPresented: $showAdsAndAppFunctionality) {
                ShowAdsAndAppFunctionalityView(onConfirm: {
                    showAdsAndAppFunctionality = false
                })
            }
        }
    }
    
    func startSOS() {
        let morseSOS: [[Bool]] = [morseDot, morseDot, morseDot, morseDash, morseDash, morseDash, morseDot, morseDot, morseDot]
        var sequence = [Bool]()
        for morseSignal in morseSOS {
            sequence.append(contentsOf: morseSignal)
            sequence.append(false) // Add gap between signals
        }
        
        var currentIndex = 0
        flashTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if currentIndex < sequence.count {
                let value = sequence[currentIndex]
                toggleFlash(on: value)
                toggleScreen(on: value)
                currentIndex += 1
            } else {
                timer.invalidate()
                Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                    if self.isSOSActive {
                        self.startSOS()
                    }
                }
            }
        }
        flashTimer?.fire()
    }
    
    func stopSOS() {
        flashTimer?.invalidate()
        flashTimer = nil
        turnOffFlash()
        screenColor = .black
    }
    
    func toggleFlash(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        try? device.lockForConfiguration()
        device.torchMode = on ? .on : .off
        device.unlockForConfiguration()
    }
    
    func toggleScreen(on: Bool) {
        screenColor = on ? .white : .black
    }
    
    func turnOffFlash() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        try? device.lockForConfiguration()
        device.torchMode = .off
        device.unlockForConfiguration()
    }
}



// MARK: - Ads and App Functionality View

// View showing information about ads and the app functionality
struct ShowAdsAndAppFunctionalityView: View {
    var onConfirm: () -> Void

    var body: some View {
        ScrollView {
            VStack {
                // Section header
                HStack {
                    Text("Ads & App Functionality")
                        .font(.title3.bold())
                    Spacer()
                }
                Divider().background(Color.gray)

                // Ads section
                VStack {
                    // Ads header
                    HStack {
                        Text("Ads")
                            .font(.largeTitle.bold())
                        Spacer()
                    }
                    // Ad image with link
                    ZStack {
                        Image("threedollar")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .cornerRadius(25)
                            .clipped()
                            .onTapGesture {
                                if let url = URL(string: "https://b33.biz/three-dollar/") {
                                    UIApplication.shared.open(url)
                                }
                            }
                    }
                    
                    // App Cards for ads
                    VStack {
                        Divider().background(Color.gray)
                        AppCardView(imageName: "bodycam", appName: "BODYCam", appDescription: "Record videos effortlessly and discreetly.", appURL: "https://apps.apple.com/id/app/b0dycam/id6496689003")
                        Divider().background(Color.gray)

                        AppCardView(imageName: "timetell", appName: "TimeTell", appDescription: "Announce the time every 30 seconds, no more guessing and checking your watch, for time-sensitive tasks.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
                        Divider().background(Color.gray)

                        AppCardView(imageName: "SingLoop", appName: "Sing LOOP", appDescription: "Record your voice effortlessly, and play it back in a loop.", appURL: "https://apps.apple.com/id/app/sing-l00p/id6480459464")
                        Divider().background(Color.gray)

                        AppCardView(imageName: "loopspeak", appName: "LOOPSpeak", appDescription: "Type or paste your text, play in loop, and enjoy hands-free narration.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
                        Divider().background(Color.gray)

                        AppCardView(imageName: "insomnia", appName: "Insomnia Sheep", appDescription: "Design to ease your mind and help you relax leading up to sleep.", appURL: "https://apps.apple.com/id/app/insomnia-sheep/id6479727431")
                        Divider().background(Color.gray)

                        AppCardView(imageName: "dryeye", appName: "Dry Eye Read", appDescription: "The go-to solution for a comfortable reading experience, by adjusting font size and color to suit your reading experience.", appURL: "https://apps.apple.com/id/app/dry-eye-read/id6474282023")
                        Divider().background(Color.gray)

                        AppCardView(imageName: "iprogram", appName: "iProgramMe", appDescription: "Custom affirmations, schedule notifications, stay inspired daily.", appURL: "https://apps.apple.com/id/app/iprogramme/id6470770935")
                        Divider().background(Color.gray)

                        AppCardView(imageName: "temptation", appName: "TemptationTrack", appDescription: "One button to track milestones, monitor progress, stay motivated.", appURL: "https://apps.apple.com/id/app/temptationtrack/id6471236988")
                        Divider().background(Color.gray)
                    }
                    Spacer()
                }
                .padding()
                .cornerRadius(15.0)

                // App functionality section
                HStack {
                    Text("App Functionality")
                        .font(.title.bold())
                    Spacer()
                }

                Text("""
                • Press 'Start SOS' to activate the SOS signal.
                • The screen and flash will blink in SOS pattern (three short signals, three long signals, and three short signals again).
                • Press 'Stop SOS' to deactivate the signal and stop the blinking.
                """)
                .font(.title3)
                .multilineTextAlignment(.leading)
                .padding()

                Spacer()

                HStack {
                    Text("SOS Light is developed by Three Dollar.")
                        .font(.title3.bold())
                    Spacer()
                }

                // Close button
                Button("Close") {
                    onConfirm()
                }
                .font(.title)
                .padding()
                .cornerRadius(25.0)
            }
            .padding()
            .cornerRadius(15.0)
        }
    }
}

// MARK: - Ads App Card View

// View displaying individual ads app cards
struct AppCardView: View {
    var imageName: String
    var appName: String
    var appDescription: String
    var appURL: String

    var body: some View {
        HStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .cornerRadius(7)

            VStack(alignment: .leading) {
                Text(appName)
                    .font(.title3)
                Text(appDescription)
                    .font(.caption)
            }
            .frame(alignment: .leading)

            Spacer()

            // Try button
            Button(action: {
                if let url = URL(string: appURL) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Try")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

*/


/*
import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var isSOSActive = false
    @State private var flashTimer: Timer?
    @State private var screenColor: Color = .black
    
    // Define Morse code patterns
    let morseDot: [Bool] = [true] // Dot in Morse code
    let morseDash: [Bool] = [true, true, true] // Dash in Morse code
    
    var body: some View {
        VStack {
            Text("SOS Light")
                .font(.largeTitle)
                .padding()
            
            Spacer()
            
            if isSOSActive {
                Text("SOS Active")
                    .font(.title)
                    .foregroundColor(.red)
                    .padding()
            } else {
                Text("SOS Inactive")
                    .font(.title)
                    .foregroundColor(.gray)
                    .padding()
            }
            
            Spacer()
            
            Button(action: {
                isSOSActive.toggle()
                if isSOSActive {
                    startSOS()
                } else {
                    stopSOS()
                }
            }) {
                Text(isSOSActive ? "Stop SOS" : "Start SOS")
                    .font(.title)
                    .padding()
                    .background(isSOSActive ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .background(screenColor)
        .edgesIgnoringSafeArea(.all)
    }
    
    func startSOS() {
        let morseSOS: [[Bool]] = [morseDot, morseDot, morseDot, morseDash, morseDash, morseDash, morseDot, morseDot, morseDot]
        var sequence = [Bool]()
        for morseSignal in morseSOS {
            sequence.append(contentsOf: morseSignal)
            sequence.append(false) // Add gap between signals
        }
        
        var currentIndex = 0
        flashTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if currentIndex < sequence.count {
                let value = sequence[currentIndex]
                toggleFlash(on: value)
                toggleScreen(on: value)
                currentIndex += 1
            } else {
                timer.invalidate()
                Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                    startSOS()
                }
            }
        }
        flashTimer?.fire()
    }
    
    func stopSOS() {
        flashTimer?.invalidate()
        flashTimer = nil
        turnOffFlash()
        screenColor = .black
    }
    
    func toggleFlash(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        try? device.lockForConfiguration()
        device.torchMode = on ? .on : .off
        device.unlockForConfiguration()
    }
    
    func toggleScreen(on: Bool) {
        screenColor = on ? .white : .black
    }
    
    func turnOffFlash() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        try? device.lockForConfiguration()
        device.torchMode = .off
        device.unlockForConfiguration()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
 
 */


/*
//good but want to put ads
import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var isSOSActive = false
    @State private var flashTimer: Timer?
    @State private var screenColor: Color = .black
    
    // Define Morse code patterns
    let morseDot: [Bool] = [true] // Dot in Morse code
    let morseDash: [Bool] = [true, true, true] // Dash in Morse code
    
    var body: some View {
        GeometryReader { geometry in
            
            VStack {
                Text("SOS Light")
                    .font(.largeTitle)
                    .padding()
                
                Spacer()
                
                if isSOSActive {
                    Text("SOS Active")
                        .font(.title)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    Text("SOS Inactive")
                        .font(.title)
                        .foregroundColor(.gray)
                        .padding()
                }
                
                Spacer()
                
                Button(action: {
                    isSOSActive.toggle()
                    if isSOSActive {
                        startSOS()
                    } else {
                        stopSOS()
                    }
                }) {
                    Text(isSOSActive ? "Stop SOS" : "Start SOS")
                        .font(.title)
                        .padding()
                        .background(isSOSActive ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(screenColor.edgesIgnoringSafeArea(.all))
        }
    }
    
    func startSOS() {
        let morseSOS: [[Bool]] = [morseDot, morseDot, morseDot, morseDash, morseDash, morseDash, morseDot, morseDot, morseDot]
        var sequence = [Bool]()
        for morseSignal in morseSOS {
            sequence.append(contentsOf: morseSignal)
            sequence.append(false) // Add gap between signals
        }
        
        var currentIndex = 0
        flashTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if currentIndex < sequence.count {
                let value = sequence[currentIndex]
                toggleFlash(on: value)
                toggleScreen(on: value)
                currentIndex += 1
            } else {
                timer.invalidate()
                Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                    if self.isSOSActive {
                        self.startSOS()
                    }
                }
            }
        }
        flashTimer?.fire()
    }
    
    func stopSOS() {
        flashTimer?.invalidate()
        flashTimer = nil
        turnOffFlash()
        screenColor = .black
    }
    
    func toggleFlash(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        try? device.lockForConfiguration()
        device.torchMode = on ? .on : .off
        device.unlockForConfiguration()
    }
    
    func toggleScreen(on: Bool) {
        screenColor = on ? .white : .black
    }
    
    func turnOffFlash() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        try? device.lockForConfiguration()
        device.torchMode = .off
        device.unlockForConfiguration()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

*/

/*
import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var isSOSActive = false
    @State private var flashTimer: Timer?
    @State private var screenColor: Color = .black
    
    // Define Morse code patterns
    let morseDot: [Bool] = [true] // Dot in Morse code
    let morseDash: [Bool] = [true, true, true] // Dash in Morse code
    
    var body: some View {
        VStack {
            Text("SOS Light")
                .font(.largeTitle)
                .padding()
            
            Spacer()
            
            if isSOSActive {
                Text("SOS Active")
                    .font(.title)
                    .foregroundColor(.red)
                    .padding()
            } else {
                Text("SOS Inactive")
                    .font(.title)
                    .foregroundColor(.gray)
                    .padding()
            }
            
            Spacer()
            
            Button(action: {
                isSOSActive.toggle()
                if isSOSActive {
                    startSOS()
                } else {
                    stopSOS()
                }
            }) {
                Text(isSOSActive ? "Stop SOS" : "Start SOS")
                    .font(.title)
                    .padding()
                    .background(isSOSActive ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .background(screenColor)
        .edgesIgnoringSafeArea(.all)
    }
    
    func startSOS() {
        let morseSOS: [[Bool]] = [morseDot, morseDot, morseDot, morseDash, morseDash, morseDash, morseDot, morseDot, morseDot]
        var sequence = [Bool]()
        for morseSignal in morseSOS {
            sequence.append(contentsOf: morseSignal)
            sequence.append(false) // Add gap between signals
        }
        
        var currentIndex = 0
        flashTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if currentIndex < sequence.count {
                let value = sequence[currentIndex]
                toggleFlash(on: value)
                toggleScreen(on: value)
                currentIndex += 1
            } else {
                timer.invalidate()
                Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                    startSOS()
                }
            }
        }
        flashTimer?.fire()
    }
    
    func stopSOS() {
        flashTimer?.invalidate()
        flashTimer = nil
        turnOffFlash()
        screenColor = .black
    }
    
    func toggleFlash(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        try? device.lockForConfiguration()
        device.torchMode = on ? .on : .off
        device.unlockForConfiguration()
    }
    
    func toggleScreen(on: Bool) {
        screenColor = on ? .white : .black
    }
    
    func turnOffFlash() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        try? device.lockForConfiguration()
        device.torchMode = .off
        device.unlockForConfiguration()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

*/

/*
//good but want sos morse code signal
import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var isSOSActive = false
    @State private var flashTimer: Timer?
    @State private var screenColor: Color = .black
    
    var body: some View {
        ZStack {
            VStack {
                Text("SOS Light")
                    .font(.largeTitle)
                    .padding()
                
                Spacer()
                
                if isSOSActive {
                    Text("")
                        .font(.title)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    Text("")
                        .font(.title)
                        .foregroundColor(.gray)
                        .padding()
                }
                
                Spacer()
                
                Button(action: {
                    isSOSActive.toggle()
                    if isSOSActive {
                        startSOS()
                    } else {
                        stopSOS()
                    }
                }) {
                    Text(isSOSActive ? "Stop SOS" : "Start SOS")
                        .font(.title)
                        .padding()
                        .background(isSOSActive ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            
        }
        .background(screenColor.edgesIgnoringSafeArea(.all))
    }
    
    func startSOS() {
        flashTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            toggleFlash()
            toggleScreen()
        }
        flashTimer?.fire()
    }
    
    func stopSOS() {
        flashTimer?.invalidate()
        flashTimer = nil
        turnOffFlash()
        screenColor = .black
    }
    
    func toggleFlash() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        try? device.lockForConfiguration()
        if device.torchMode == .off {
            try? device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
        } else {
            device.torchMode = .off
        }
        device.unlockForConfiguration()
    }
    
    func toggleScreen() {
        screenColor = screenColor == .black ? .white : .black
    }
    
    func turnOffFlash() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        try? device.lockForConfiguration()
        device.torchMode = .off
        device.unlockForConfiguration()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


#Preview {
    ContentView()
}

*/

/*


import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
*/
