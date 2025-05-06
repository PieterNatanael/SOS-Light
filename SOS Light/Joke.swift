//
//  Joke.swift
//  SOS Light
//
//  Created by Pieter Yoshua Natanael on 30/04/25.
//

import SwiftUI
import StoreKit

struct Joke: Decodable {
    let setup: String
    let punchline: String
}

struct SOSRelaxView: View {
    @State private var joke: Joke?
    @State private var showPunchline = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingSheet = false
    @State private var showingLegalInfo = false
    @State private var showUpgradeAlert = false

    @StateObject private var subscriptionManager = SubscriptionManager.shared

    private let dailyLimit = 3
    private let jokeCountKey = "jokeCount"
    private let lastUsedDateKey = "lastUsedDate"

    var body: some View {
        VStack(spacing: 20) {
            Text("SOS Relax")
                .font(.largeTitle)
                .bold()

            if let joke = joke {
                Text(joke.setup)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding()

                if showPunchline {
                    Text(joke.punchline)
                        .font(.title.bold())
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    Button("Show Answer") {
                        showPunchline = true
                    }
                    .font(.title)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            } else if isLoading {
                ProgressView("Generating a joke...")
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            } else {
                Text("Tap below to get a light-hearted joke.")
                    .multilineTextAlignment(.center)
            }

            Button("Tell me a Joke") {
                Task {
                    await fetchJokeIfAllowed()
                }
            }
            .font(.title)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(#colorLiteral(red: 0.4500938654, green: 0.9813225865, blue: 0.4743030667, alpha: 1)))
            .foregroundColor(.black)
            .cornerRadius(10)
            .disabled(isLoading)
            
            Text("In emergencies, try to stay calm, cool, and relaxed. Don’t panic.")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            if subscriptionManager.isSubscribed {
                Text("✅ You are recognized as an SOS Light Supporter. Thank you for your support.")
                    .foregroundColor(.green)
                    .font(.footnote)
            }

            Button(action: {
                showingSheet = true
            }) {
                Text("❤️ Love SOS Light?")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(12)
                    .shadow(radius: 4)
                    .padding(.horizontal)
                    .padding(.bottom, 10)
            }

//            Button("❤️ Love SOS Light?") {
//                showingSheet = true
//            }
//            .font(.headline)
//            .padding(.bottom, 10)
//            
            
            
        }
        .padding()
        .sheet(isPresented: $showingSheet) {
            SubscriptionView(isPresented: $showingSheet, showingLegalInfo: $showingLegalInfo)
        }
        .alert(isPresented: $showUpgradeAlert) {
            Alert(
                title: Text("Daily Limit Reached"),
                message: Text("Please subscribe to unlock the full version!"),
                primaryButton: .default(Text("Subscribe")) {
                    showingSheet = true
                },
                secondaryButton: .cancel(Text("Maybe Later"))
            )
        }
        .onAppear {
            Task {
                await subscriptionManager.loadProducts()
                resetIfNewDay()
            }
        }
    }

    // MARK: - Joke Fetch Logic
    
    

    func fetchJokeIfAllowed() async {
        if subscriptionManager.isSubscribed || canFetchJoke() {
            incrementJokeCount()
            await fetchJoke()
        } else {
            showUpgradeAlert = true
        }
    }

    func fetchJoke() async {
        joke = nil
        showPunchline = false
        isLoading = true
        errorMessage = nil

        guard let url = URL(string: "https://official-joke-api.appspot.com/random_joke") else {
            errorMessage = "Invalid joke URL."
            isLoading = false
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(Joke.self, from: data)
            joke = decoded
        } catch {
            errorMessage = "Failed to fetch joke: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Daily Limit Handling

    func canFetchJoke() -> Bool {
        resetIfNewDay()
        return getJokeCountToday() < dailyLimit
    }

    func getJokeCountToday() -> Int {
        UserDefaults.standard.integer(forKey: jokeCountKey)
    }

    func incrementJokeCount() {
        let count = getJokeCountToday() + 1
        UserDefaults.standard.set(count, forKey: jokeCountKey)
        UserDefaults.standard.set(Date(), forKey: lastUsedDateKey)
    }
    
    

    func resetIfNewDay() {
        guard let lastUsed = UserDefaults.standard.object(forKey: lastUsedDateKey) as? Date else {
            return
        }
        if !Calendar.current.isDateInToday(lastUsed) {
            UserDefaults.standard.set(0, forKey: jokeCountKey)
        }
    }
}

// Separate view for subscription to improve code organization
struct SubscriptionView: View {
    @Binding var isPresented: Bool
    @Binding var showingLegalInfo: Bool
    
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🌟 Support SOS Light")
                  .font(.title2)
                  .fontWeight(.bold)
                  .multilineTextAlignment(.center)

              Text("""
          Our mission with SOS Light is to be a trusted helper in emergencies — bringing key tools into one app to keep people safe, visible, and supported when it matters most.
          """)
                  .font(.title3)
                  .multilineTextAlignment(.center)
                  .padding(.horizontal)
              
            
            if subscriptionManager.isLoading {
                ProgressView("Loading...")
            } else if let errorMessage = subscriptionManager.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            if !subscriptionManager.products.isEmpty, let product = subscriptionManager.products.first {
                VStack(alignment: .leading, spacing: 8) {
                    Text("SOS Light Full Version")
                        .font(.headline)
                        .padding(.top)
                    
                    Text("Full access to all features to stay ready in emergency.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Limited Time Offer!")
                        .font(.headline)
                         .foregroundColor(.red)
                         .bold()
                    
//                    Text("\("$\(Double(product.displayPrice.replacingOccurrences(of: "$", with: ""))! * 8)") per year")
//                        .strikethrough(true, color: .red)
//                        .font(.headline)
//                        .foregroundColor(.green)
                    Text("\(priceText(from: product.displayPrice)) per year")
                        .strikethrough(true, color: .red)
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    Text("\(product.displayPrice) per year")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            } else {
                Text("Full Version to stay ready in emergency.")
                    .multilineTextAlignment(.center)
                
                
                
//                Text("$2.99 per year")
//                    .font(.headline)
//                    .foregroundColor(.green)
            }
            
            Button(action: {
                Task {
                    await subscriptionManager.purchase()
                }
            }) {
                Text(subscriptionManager.isSubscribed ? "Subscribed ✅" : "Subscribe")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(subscriptionManager.isSubscribed ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(subscriptionManager.isSubscribed || subscriptionManager.isLoading)
            
            Button("🔁 Restore Purchase") {
                Task {
                    await subscriptionManager.restorePurchases()
                }
            }
            .disabled(subscriptionManager.isLoading)
            
            Button("📜 Privacy Policy & Terms of Use") {
                showingLegalInfo = true
            }
            
            Button("🌟 Rate on App Store") {
                if let url = URL(string: "https://apps.apple.com/app/6504213303?action=write-review") {
                    UIApplication.shared.open(url)
                }
            }
            
            Button("❌ Close") {
                isPresented = false
            }
        }
        .padding()
        .sheet(isPresented: $showingLegalInfo) {
            LegalInfoView(isPresented: $showingLegalInfo)
        }
    }
}

func priceText(from priceString: String) -> String {
    // Extract currency symbol (non-digit, non-dot)
    let symbol = priceString.trimmingCharacters(in: .whitespaces).prefix { !$0.isNumber && $0 != "." }
    
    // Extract number
    let numberString = priceString.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
    
    if let value = Double(numberString) {
        return "\(symbol)\(String(format: "%.2f", value * 8))"
    } else {
        return "Invalid Price"
    }
}


// Separate view for legal information
struct LegalInfoView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Privacy Policy")
                .font(.title2)
                .bold()
            
            ScrollView {
                Text("""
                SOS Light does not collect, store, or track any personal information. All your data stays on your device. Your subscription is securely managed via your Apple ID and App Store account.
                """)
                .font(.body)
                .padding(.bottom)
                
                Text("Terms of Use (EULA)")
                    .font(.title2)
                    .bold()
                    .padding(.top)
                
                Text("""
                By using SOS Light, you agree to the terms of this End User License Agreement (EULA). This app is licensed to you, not sold. Your use of SOS Light is also governed by Apple's standard EULA, which can be found at:
                https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
                
                1. **License**: You are granted a non-transferable license to use SOS Light on Apple-branded devices that you own or control.
                
                2. **Subscription**: Full access is available with an annual subscription. Your subscription renews automatically unless canceled 24 hours before the end of the billing period.
                
                3. **Restrictions**: You may not copy, modify, or reverse-engineer the app. This app is provided "as is" without warranties of any kind.
                
                4. **Termination**: Violation of these terms may result in termination of your license.
                
                5. **Support**: We offer best-effort support, but do not guarantee availability or uptime.
                
                This agreement is governed by the laws of your country of residence.
                """)
                .font(.body)
            }
            
            Button("❌ Close") {
                isPresented = false
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}

#Preview {
    SOSRelaxView()
}


//import SwiftUI
//import StoreKit
//
//struct Joke: Decodable {
//    let setup: String
//    let punchline: String
//}
//
//struct SOSRelaxView: View {
//    @State private var joke: Joke?
//    @State private var showPunchline = false
//    @State private var isLoading = false
//    @State private var errorMessage: String?
//    @State private var showingSheet = false
//    @State private var showingLegalInfo = false
//    @State private var showUpgradeAlert = false
//
//    @StateObject private var subscriptionManager = SubscriptionManager.shared
//
//    private let dailyLimit = 3
//    private let jokeCountKey = "jokeCount"
//    private let lastUsedDateKey = "lastUsedDate"
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("SOS Relax")
//                .font(.largeTitle)
//                .bold()
//
//            if let joke = joke {
//                Text(joke.setup)
//                    .font(.title2)
//                    .multilineTextAlignment(.center)
//                    .padding()
//
//                if showPunchline {
//                    Text(joke.punchline)
//                        .font(.title.bold())
//                        .foregroundColor(.gray)
//                        .multilineTextAlignment(.center)
//                        .padding()
//                } else {
//                    Button("Show Answer") {
//                        showPunchline = true
//                    }
//                    .font(.title)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//                }
//            } else if isLoading {
//                ProgressView("Generating a joke...")
//            } else if let errorMessage = errorMessage {
//                Text(errorMessage)
//                    .foregroundColor(.red)
//                    .multilineTextAlignment(.center)
//            } else {
//                Text("Tap below to get a light-hearted joke.")
//                    .multilineTextAlignment(.center)
//            }
//
//            Button("Tell me a Joke") {
//                Task {
//                    await fetchJokeIfAllowed()
//                }
//            }
//            .font(.title)
//            .frame(maxWidth: .infinity)
//            .padding()
//            .background(Color(#colorLiteral(red: 0.4500938654, green: 0.9813225865, blue: 0.4743030667, alpha: 1)))
//            .foregroundColor(.black)
//            .cornerRadius(10)
//
//            Spacer()
//
//            if subscriptionManager.isSubscribed {
//                Text("✅ You're a Premium Subscriber!")
//                    .foregroundColor(.green)
//                    .font(.footnote)
//            }
//
//            Button("❤️ Love SOS Light?") {
//                showingSheet = true
//            }
//            .font(.headline)
//            .padding(.bottom, 10)
//        }
//        .padding()
//        .sheet(isPresented: $showingSheet) {
//            VStack(spacing: 20) {
//                Text("🌟 Support SOS Light")
//                    .font(.title2)
//                    .bold()
//
//                
//                Text("SOS Light Full Version")
//                    .font(.headline)
//                    .padding(.top)
//
//                Text("Unlimited Full Version to stay ready in every emergency.")
//                    .multilineTextAlignment(.center)
//
//                Button(action: {
//                               Task {
//                                   await subscriptionManager.purchase()
//                               }
//                           }) {
//                               Text(subscriptionManager.isSubscribed ? "Subscribed ✅" : "Subscribe Now 💰")
//                                   .frame(maxWidth: .infinity)
//                                   .padding()
//                                   .background(subscriptionManager.isSubscribed ? Color.gray : Color.blue)
//                                   .foregroundColor(.white)
//                                   .cornerRadius(10)
//                           }
//                           .disabled(subscriptionManager.isSubscribed)
//
//                Button("🔁 Restore Purchase") {
//                    Task {
//                        await subscriptionManager.restorePurchases()
//                    }
//                }
//
//
//                Button("📜 Privacy Policy & Terms of Use") {
//                    showingLegalInfo = true
//                }
//                Button("🌟 Rate on App Store") {
//                    if let url = URL(string: "https://apps.apple.com/app/6504213303?action=write-review") {
//                        UIApplication.shared.open(url)
//                    }
//                }
//
//                Button("❌ Close") {
//                    showingSheet = false
//                }
//            }
//            .padding()
//            .sheet(isPresented: $showingLegalInfo) {
//                VStack(alignment: .leading, spacing: 20) {
//                    Text("Privacy Policy")
//                        .font(.title2)
//                        .bold()
//
//                    ScrollView {
//                        Text("""
//                        SOS Light does not collect, store, or track any personal information. All your data stays on your device. Your subscription is securely managed via your Apple ID and App Store account.
//                        """)
//                        .font(.body)
//                        .padding(.bottom)
//
//                        Text("Terms of Use (EULA)")
//                            .font(.title2)
//                            .bold()
//                            .padding(.top)
//
//                        Text("""
//                        By using SOS Light, you agree to the terms of this End User License Agreement (EULA). This app is licensed to you, not sold. Your use of SOS Light is also governed by Apple's standard EULA, which can be found at:
//                        https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
//
//                        1. **License**: You are granted a non-transferable license to use SOS Light on Apple-branded devices that you own or control.
//
//                        2. **Subscription**: Full access is available with an annual subscription. Your subscription renews automatically unless canceled 24 hours before the end of the billing period.
//
//                        3. **Restrictions**: You may not copy, modify, or reverse-engineer the app. This app is provided "as is" without warranties of any kind.
//
//                        4. **Termination**: Violation of these terms may result in termination of your license.
//
//                        5. **Support**: We offer best-effort support, but do not guarantee availability or uptime.
//
//                        This agreement is governed by the laws of your country of residence.
//                        """)
//                        .font(.body)
//                    }
//
//                    Button("❌ Close") {
//                        showingLegalInfo = false
//                    }
//                }
//                .padding()
//            }
//        }
//        .alert(isPresented: $showUpgradeAlert) {
//            Alert(
//                title: Text("Daily Limit Reached"),
//                message: Text("Please subscribe to unlock the full version!"),
//                primaryButton: .default(Text("Subscribe")) {
//                    showingSheet = true
//                },
//                secondaryButton: .cancel(Text("Maybe Later"))
//            )
//        }
//        .onAppear {
//            Task {
//                await subscriptionManager.loadProducts()
//                resetIfNewDay()
//            }
//        }
//    }
//
//    // MARK: - Joke Fetch Logic
//
//    func fetchJokeIfAllowed() async {
//        if subscriptionManager.isSubscribed || canFetchJoke() {
//            incrementJokeCount()
//            await fetchJoke()
//        } else {
//            showUpgradeAlert = true
//        }
//    }
//
//    func fetchJoke() async {
//        joke = nil
//        showPunchline = false
//        isLoading = true
//        errorMessage = nil
//
//        guard let url = URL(string: "https://official-joke-api.appspot.com/random_joke") else {
//            errorMessage = "Invalid joke URL."
//            isLoading = false
//            return
//        }
//
//        do {
//            let (data, _) = try await URLSession.shared.data(from: url)
//            let decoded = try JSONDecoder().decode(Joke.self, from: data)
//            joke = decoded
//        } catch {
//            errorMessage = error.localizedDescription
//        }
//
//        isLoading = false
//    }
//
//    // MARK: - Daily Limit Handling
//
//    func canFetchJoke() -> Bool {
//        resetIfNewDay()
//        return getJokeCountToday() < dailyLimit
//    }
//
//    func getJokeCountToday() -> Int {
//        UserDefaults.standard.integer(forKey: jokeCountKey)
//    }
//
//    func incrementJokeCount() {
//        let count = getJokeCountToday() + 1
//        UserDefaults.standard.set(count, forKey: jokeCountKey)
//        UserDefaults.standard.set(Date(), forKey: lastUsedDateKey)
//    }
//
//    func resetIfNewDay() {
//        guard let lastUsed = UserDefaults.standard.object(forKey: lastUsedDateKey) as? Date else {
//            return
//        }
//        if !Calendar.current.isDateInToday(lastUsed) {
//            UserDefaults.standard.set(0, forKey: jokeCountKey)
//        }
//    }
//}
//
//#Preview {
//    SOSRelaxView()
//}
//

//change to store kit 2 and ios 15.3
//import SwiftUI
//import StoreKit
//
//struct Joke: Decodable {
//    let setup: String
//    let punchline: String
//}
//
//struct SOSRelaxView: View {
//    @State private var joke: Joke?
//    @State private var showPunchline = false
//    @State private var isLoading = false
//    @State private var errorMessage: String?
//    @State private var showingSheet = false
//    @State private var showingLegalInfo = false
//    @State private var showUpgradeAlert = false
//
//    @ObservedObject private var iap = InAppPurchaseManager.shared
//
//    private let dailyLimit = 3
//    private let jokeCountKey = "jokeCount"
//    private let lastUsedDateKey = "lastUsedDate"
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("SOS Relax")
//                .font(.largeTitle)
//                .bold()
//
//            if let joke = joke {
//                Text(joke.setup)
//                    .font(.title2)
//                    .multilineTextAlignment(.center)
//                    .padding()
//
//                if showPunchline {
//                    Text(joke.punchline)
//                        .font(.title.bold())
//                        .foregroundColor(.gray)
//                        .multilineTextAlignment(.center)
//                        .padding()
//                } else {
//                    Button("Show Answer") {
//                        showPunchline = true
//                    }
//                    .font(.title)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//                }
//            } else if isLoading {
//                ProgressView("Generating a joke...")
//            } else if let errorMessage = errorMessage {
//                Text(errorMessage)
//                    .foregroundColor(.red)
//                    .multilineTextAlignment(.center)
//            } else {
//                Text("Tap below to get a light-hearted joke.")
//                    .multilineTextAlignment(.center)
//            }
//
//            Button("Tell me a Joke") {
//                Task {
//                    await fetchJokeIfAllowed()
//                }
//            }
//            .font(.title)
//            .frame(maxWidth: .infinity)
//            .padding()
//            .background(Color(#colorLiteral(red: 0.4500938654, green: 0.9813225865, blue: 0.4743030667, alpha: 1)))
//            .foregroundColor(.black)
//            .cornerRadius(10)
//
//            Spacer()
//
//            if iap.isSubscribed {
//                Text("✅ You're a Premium Subscriber!")
//                    .foregroundColor(.green)
//                    .font(.footnote)
//            }
//
//            Button("❤️ Love SOS Light?") {
//                showingSheet = true
//            }
//            .font(.headline)
//            .padding(.bottom, 10)
//        }
//        .padding()
//        .sheet(isPresented: $showingSheet) {
//            VStack(spacing: 20) {
//                Text("🌟 Support SOS Light")
//                    .font(.title2)
//                    .bold()
//
//                if iap.product != nil {
//                    Text("SOS Light Full Version")
//                        .font(.headline)
//                        .padding(.top)
//
//                    Text("Unlimited Full Version to stay ready in every emergency.")
//                        .multilineTextAlignment(.center)
//
//                    if let product = iap.product {
//                        Button("💰 Subscribe for \(product.priceLocale.currencySymbol ?? "$")\(product.price) / year") {
//                            iap.buySubscription()
//                        }
//                    }
//                    Button("🔁 Restore Purchase") {
//                        SKPaymentQueue.default().restoreCompletedTransactions()
//                    }
//
//                    Text("Subscription auto-renews unless cancelled at least 24h before the end of the current period.")
//                        .font(.footnote)
//                        .multilineTextAlignment(.center)
//                        .padding(.top)
//                } else {
//                    Text("Loading subscription info...")
//                }
//
//                Button("📜 Privacy Policy & Terms of Use") {
//                    showingLegalInfo = true
//                }
//                                Button("🌟 Rate on App Store") {
//                                    if let url = URL(string: "https://apps.apple.com/app/6504213303?action=write-review") {
//                                        UIApplication.shared.open(url)
//                                    }
//                                }
//
//                Button("❌ Close") {
//                    showingSheet = false
//                }
//            }
//            .padding()
//            .sheet(isPresented: $showingLegalInfo) {
//                VStack(alignment: .leading, spacing: 20) {
//                    Text("Privacy Policy")
//                        .font(.title2)
//                        .bold()
//
//                    ScrollView {
//                        Text("""
//                        SOS Light does not collect, store, or track any personal information. All your data stays on your device. Your subscription is securely managed via your Apple ID and App Store account. We do not collect analytics or behavioral data.
//                        """)
//                        .font(.body)
//                        .padding(.bottom)
//
//                        Text("Terms of Use (EULA)")
//                            .font(.title2)
//                            .bold()
//                            .padding(.top)
//
//                        Text("""
//                        By using SOS Light, you agree to the terms of this End User License Agreement (EULA). This app is licensed to you, not sold. Your use of SOS Light is also governed by Apple's standard EULA, which can be found at:
//                        https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
//
//                        1. **License**: You are granted a non-transferable license to use SOS Light on Apple-branded devices that you own or control.
//
//                        2. **Subscription**: Full access is available with an annual subscription. Your subscription renews automatically unless canceled 24 hours before the end of the billing period.
//
//                        3. **Restrictions**: You may not copy, modify, or reverse-engineer the app. This app is provided "as is" without warranties of any kind.
//
//                        4. **Termination**: Violation of these terms may result in termination of your license.
//
//                        5. **Support**: We offer best-effort support, but do not guarantee availability or uptime.
//
//                        This agreement is governed by the laws of your country of residence.
//                        """)
//                        .font(.body)
//                    }
//
//                    Button("❌ Close") {
//                        showingLegalInfo = false
//                    }
//                }
//                .padding()
//
//                
//                
//                
//                
//                
//            }
//        }
//        .alert(isPresented: $showUpgradeAlert) {
//            Alert(
//                title: Text("Daily Limit Reached"),
//                message: Text("Please subscribe to unlock the full version!"),
//                primaryButton: .default(Text("Subscribe")) {
//                    showingSheet = true
//                },
//                secondaryButton: .cancel(Text("Maybe Later"))
//            )
//        }
//        .onAppear {
//            InAppPurchaseManager.shared.fetchProduct()
//            resetIfNewDay()
//        }
//    }
//
//    // MARK: - Joke Fetch Logic
//
//    func fetchJokeIfAllowed() async {
//        if iap.isSubscribed || canFetchJoke() {
//            incrementJokeCount()
//            await fetchJoke()
//        } else {
//            showUpgradeAlert = true
//        }
//    }
//
//    func fetchJoke() async {
//        joke = nil
//        showPunchline = false
//        isLoading = true
//        errorMessage = nil
//
//        guard let url = URL(string: "https://official-joke-api.appspot.com/random_joke") else {
//            errorMessage = "Invalid joke URL."
//            isLoading = false
//            return
//        }
//
//        do {
//            let (data, _) = try await URLSession.shared.data(from: url)
//            let decoded = try JSONDecoder().decode(Joke.self, from: data)
//            joke = decoded
//        } catch {
//            errorMessage = error.localizedDescription
//        }
//
//        isLoading = false
//    }
//
//    // MARK: - Daily Limit Handling
//
//    func canFetchJoke() -> Bool {
//        resetIfNewDay()
//        return getJokeCountToday() < dailyLimit
//    }
//
//    func getJokeCountToday() -> Int {
//        UserDefaults.standard.integer(forKey: jokeCountKey)
//    }
//
//    func incrementJokeCount() {
//        let count = getJokeCountToday() + 1
//        UserDefaults.standard.set(count, forKey: jokeCountKey)
//        UserDefaults.standard.set(Date(), forKey: lastUsedDateKey)
//    }
//
//    func resetIfNewDay() {
//        guard let lastUsed = UserDefaults.standard.object(forKey: lastUsedDateKey) as? Date else {
//            return
//        }
//        if !Calendar.current.isDateInToday(lastUsed) {
//            UserDefaults.standard.set(0, forKey: jokeCountKey)
//        }
//    }
//}
//
//#Preview {
//    SOSRelaxView()
//}
//
//import SwiftUI
//import StoreKit
//
//struct Joke: Decodable {
//    let setup: String
//    let punchline: String
//}
//
//struct SOSRelaxView: View {
//    @State private var joke: Joke?
//    @State private var showPunchline = false
//    @State private var isLoading = false
//    @State private var errorMessage: String?
//    @State private var showingSheet = false
//    @State private var showUpgradeAlert = false
//
//    @ObservedObject private var iap = InAppPurchaseManager.shared
//
//    private let dailyLimit = 3
//    private let jokeCountKey = "jokeCount"
//    private let lastUsedDateKey = "lastUsedDate"
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("SOS Relax")
//                .font(.largeTitle)
//                .bold()
//
//            if let joke = joke {
//                Text(joke.setup)
//                    .font(.title2)
//                    .multilineTextAlignment(.center)
//                    .padding()
//
//                if showPunchline {
//                    Text(joke.punchline)
//                        .font(.title.bold())
//                        .foregroundColor(.gray)
//                        .multilineTextAlignment(.center)
//                        .padding()
//                } else {
//                    Button("Show Answer") {
//                        showPunchline = true
//                    }
//                    .font(.title)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//                }
//            } else if isLoading {
//                ProgressView("Generating a joke...")
//            } else if let errorMessage = errorMessage {
//                Text(errorMessage)
//                    .foregroundColor(.red)
//                    .multilineTextAlignment(.center)
//            } else {
//                Text("Tap below to get a light-hearted joke.")
//                    .multilineTextAlignment(.center)
//            }
//
//            Button("Tell me a Joke") {
//                Task {
//                    await fetchJokeIfAllowed()
//                }
//            }
//            .font(.title)
//            .frame(maxWidth: .infinity)
//            .padding()
//            .background(Color(#colorLiteral(red: 0.4500938654, green: 0.9813225865, blue: 0.4743030667, alpha: 1)))
//            .foregroundColor(.black)
//            .cornerRadius(10)
//
//            Spacer()
//
//            if iap.isSubscribed {
//                Text("✅ You're a Premium Subscriber!")
//                    .foregroundColor(.green)
//                    .font(.footnote)
//            }
//
//            Button("❤️ Love SOS Light?") {
//                showingSheet = true
//            }
//            .font(.footnote)
//            .padding(.bottom, 10)
//        }
//        .padding()
//        .sheet(isPresented: $showingSheet) {
//            VStack(spacing: 20) {
//                Text("❤️ Love SOS Light?")
//                    .font(.title2)
//                    .bold()
//
//                Button("🌟 Rate on App Store") {
//                    if let url = URL(string: "https://apps.apple.com/app/6504213303?action=write-review") {
//                        UIApplication.shared.open(url)
//                    }
//                }
//
//                if let product = iap.product {
//                    Button("💰 Subscribe for \(product.priceLocale.currencySymbol ?? "$")\(product.price)") {
//                        iap.buySubscription()
//                    }
//                } else {
//                    Text("Loading price...")
//                }
//
//                Button("❌ Close") {
//                    showingSheet = false
//                }
//            }
//            .padding()
//        }
//        .alert(isPresented: $showUpgradeAlert) {
//            Alert(
//                title: Text("Daily Limit Reached"),
//                message: Text("You’ve reached your free daily limit of 3 jokes. Subscribe to unlock SOS Light Full Version!"),
//                primaryButton: .default(Text("Subscribe")) {
//                    showingSheet = true
//                },
//                secondaryButton: .cancel(Text("Maybe Later"))
//            )
//        }
//        .onAppear {
//            InAppPurchaseManager.shared.fetchProduct()
//            resetIfNewDay()
//        }
//    }
//
//    // MARK: - Joke Fetch Logic with async/await
//
//    func fetchJokeIfAllowed() async {
//        if iap.isSubscribed || canFetchJoke() {
//            incrementJokeCount()
//            await fetchJoke()
//        } else {
//            showUpgradeAlert = true
//        }
//    }
//
//    func fetchJoke() async {
//        joke = nil
//        showPunchline = false
//        isLoading = true
//        errorMessage = nil
//
//        guard let url = URL(string: "https://official-joke-api.appspot.com/random_joke") else {
//            errorMessage = "Invalid joke URL."
//            isLoading = false
//            return
//        }
//
//        do {
//            let (data, _) = try await URLSession.shared.data(from: url)
//            let decoded = try JSONDecoder().decode(Joke.self, from: data)
//            joke = decoded
//        } catch {
//            errorMessage = error.localizedDescription
//        }
//
//        isLoading = false
//    }
//
//    // MARK: - Joke Count Tracking
//
//    func canFetchJoke() -> Bool {
//        resetIfNewDay()
//        return getJokeCountToday() < dailyLimit
//    }
//
//    func getJokeCountToday() -> Int {
//        UserDefaults.standard.integer(forKey: jokeCountKey)
//    }
//
//    func incrementJokeCount() {
//        let count = getJokeCountToday() + 1
//        UserDefaults.standard.set(count, forKey: jokeCountKey)
//        UserDefaults.standard.set(Date(), forKey: lastUsedDateKey)
//    }
//
//    func resetIfNewDay() {
//        guard let lastUsed = UserDefaults.standard.object(forKey: lastUsedDateKey) as? Date else {
//            return
//        }
//        if !Calendar.current.isDateInToday(lastUsed) {
//            UserDefaults.standard.set(0, forKey: jokeCountKey)
//        }
//    }
//}
//
//#Preview {
//    SOSRelaxView()
//}



//import SwiftUI
//import StoreKit
//
//struct Joke: Decodable {
//    let setup: String
//    let punchline: String
//}
//
//struct SOSRelaxView: View {
//    @State private var joke: Joke?
//    @State private var showPunchline = false
//    @State private var isLoading = false
//    @State private var errorMessage: String?
//    @State private var showingSheet = false
//
//    @ObservedObject private var iap = InAppPurchaseManager.shared
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("SOS Relax")
//                .font(.largeTitle)
//                .bold()
//
//            if let joke = joke {
//                Text(joke.setup)
//                    .font(.title2)
//                    .multilineTextAlignment(.center)
//                    .padding()
//
//                if showPunchline {
//                    Text(joke.punchline)
//                        .font(.title.bold())
//                        .foregroundColor(.gray)
//                        .multilineTextAlignment(.center)
//                        .padding()
//                } else {
//                    Button("Show Answer") {
//                        showPunchline = true
//                    }
//                    .font(.title)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//                }
//            } else if isLoading {
//                ProgressView("Generating a joke...")
//            } else if let errorMessage = errorMessage {
//                Text(errorMessage)
//                    .foregroundColor(.red)
//                    .multilineTextAlignment(.center)
//            } else {
//                Text("Tap below to get a light-hearted joke.")
//                    .multilineTextAlignment(.center)
//            }
//
//            Button("Tell me a Joke") {
//                fetchJoke()
//            }
//            .font(.title)
//            .frame(maxWidth: .infinity)
//            .padding()
//            .background(Color(#colorLiteral(red: 0.4500938654, green: 0.9813225865, blue: 0.4743030667, alpha: 1)))
//            .foregroundColor(.black)
//            .cornerRadius(10)
//
//            Spacer()
//
//            if iap.isSubscribed {
//                Text("✅ You're a Premium Subscriber!")
//                    .foregroundColor(.green)
//                    .font(.footnote)
//            }
//
//            Button("❤️ Love SOS Light?") {
//                showingSheet = true
//            }
//            .font(.footnote)
//            .padding(.bottom, 10)
//        }
//        .padding()
//        .sheet(isPresented: $showingSheet) {
//            VStack(spacing: 20) {
//                Text("❤️ Love SOS Light?")
//                    .font(.title2)
//                    .bold()
//
//                Button("🌟 Rate on App Store") {
//                    if let url = URL(string: "https://apps.apple.com/app/6504213303?action=write-review") {
//                        UIApplication.shared.open(url)
//                    }
//                }
//
//                if let product = iap.product {
//                    Button("💰 Subscribe for \(product.priceLocale.currencySymbol ?? "$")\(product.price)") {
//                        iap.buySubscription()
//                    }
//                } else {
//                    Text("Loading price...")
//                }
//
//                Button("❌ Close") {
//                    showingSheet = false
//                }
//            }
//            .padding()
//        }
//        .onAppear {
//            InAppPurchaseManager.shared.fetchProduct()
//        }
//    }
//
//    func fetchJoke() {
//        joke = nil
//        showPunchline = false
//        isLoading = true
//        errorMessage = nil
//
//        guard let url = URL(string: "https://official-joke-api.appspot.com/random_joke") else {
//            errorMessage = "Invalid joke URL."
//            isLoading = false
//            return
//        }
//
//        URLSession.shared.dataTask(with: url) { data, _, error in
//            DispatchQueue.main.async {
//                isLoading = false
//                if let data = data {
//                    if let decoded = try? JSONDecoder().decode(Joke.self, from: data) {
//                        joke = decoded
//                    } else {
//                        errorMessage = "Failed to decode joke."
//                    }
//                } else if let error = error {
//                    errorMessage = error.localizedDescription
//                } else {
//                    errorMessage = "Unknown error."
//                }
//            }
//        }.resume()
//    }
//}
//
//
//#Preview {
//    SOSRelaxView()
//}

//import SwiftUI
//
//struct Joke: Decodable {
//    let setup: String
//    let punchline: String
//}
//
//struct SOSRelaxView: View {
//    @State private var joke: Joke?
//    @State private var showPunchline = false
//    @State private var isLoading = false
//    @State private var errorMessage: String?
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("SOS Relax")
//                .font(.largeTitle)
//                .bold()
//
//            if let joke = joke {
//                Text(joke.setup)
//                    .font(.title2)
//                    .multilineTextAlignment(.center)
//                    .padding()
//
//                if showPunchline {
//                    Text(joke.punchline)
//                        .font(.title.bold())
//                        .foregroundColor(.gray)
//                        .multilineTextAlignment(.center)
//                        .padding()
//                } else {
//                    Button("Show Answer") {
//                        showPunchline = true
//                    }
//                    .font(.title)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//                }
//            } else if isLoading {
//                ProgressView("Generating a joke...")
//            } else if let errorMessage = errorMessage {
//                Text(errorMessage)
//                    .foregroundColor(.red)
//                    .multilineTextAlignment(.center)
//            } else {
//                Text("Tap below to get a light-hearted joke.")
//                    .multilineTextAlignment(.center)
//            }
//
//            Button("Tell me a Joke") {
//                Task {
//                    await fetchJoke()
//                }
//            }
//            .font(.title)
//            .frame(maxWidth: .infinity)
//            .padding()
//            .background(Color(#colorLiteral(red: 0.4500938654, green: 0.9813225865, blue: 0.4743030667, alpha: 1)))
//            .foregroundColor(.black)
//            .cornerRadius(10)
//
//            Spacer()
//
//            Text("In emergencies, try to stay calm, cool, and relaxed. Don’t panic.")
//                .font(.footnote)
//                .multilineTextAlignment(.center)
//                .padding()
//        }
//        .padding()
//    }
//
//    func fetchJoke() async {
//        joke = nil
//        showPunchline = false
//        isLoading = true
//        errorMessage = nil
//
//        guard let url = URL(string: "https://official-joke-api.appspot.com/random_joke") else {
//            errorMessage = "Invalid joke URL."
//            isLoading = false
//            return
//        }
//
//        do {
//            let (data, _) = try await URLSession.shared.data(from: url)
//            if let decoded = try? JSONDecoder().decode(Joke.self, from: data) {
//                joke = decoded
//            } else {
//                errorMessage = "Failed to decode joke."
//            }
//        } catch {
//            errorMessage = error.localizedDescription
//        }
//
//        isLoading = false
//    }
//}
//
//#Preview {
//    SOSRelaxView()
//}


//import SwiftUI
//
//struct Joke: Decodable {
//    let setup: String
//    let punchline: String
//}
//
//struct SOSRelaxView: View {
//    @State private var joke: Joke?
//    @State private var showPunchline = false
//    @State private var isLoading = false
//    @State private var errorMessage: String?
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("SOS Relax")
//                .font(.largeTitle)
//                .bold()
//
//            if let joke = joke {
//                Text(joke.setup)
//                    .font(.title2)
//                    .multilineTextAlignment(.center)
//                    .padding()
//
//                if showPunchline {
//                    Text(joke.punchline)
//                        .font(.title.bold())
//                        .foregroundColor(.gray)
//                        .multilineTextAlignment(.center)
//                        .padding()
//                } else {
//                    Button("Show Answer") {
//                        showPunchline = true
//                    }
//                    .font(.title)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//                }
//            } else if isLoading {
//                ProgressView("Generating a joke...")
//            } else if let errorMessage = errorMessage {
//                Text(errorMessage)
//                    .foregroundColor(.red)
//                    .multilineTextAlignment(.center)
//            } else {
//                Text("Tap below to get a light-hearted joke.")
//                    .multilineTextAlignment(.center)
//            }
//
//            Button("Tell me a Joke") {
//                fetchJoke()
//            }
//            .font(.title)
//            .frame(maxWidth: .infinity)
//            .padding()
//            .background(Color(#colorLiteral(red: 0.4500938654, green: 0.9813225865, blue: 0.4743030667, alpha: 1)))
//            .foregroundColor(.black)
//            .cornerRadius(10)
//
//            Spacer()
//
//            Text("In emergencies, try to stay calm, cool, and relaxed. Don’t panic.")
//                .font(.footnote)
//                .foregroundColor(.secondary)
//                .multilineTextAlignment(.center)
//                .padding()
//        }
//        .padding()
//    }
//
//    func fetchJoke() {
//        joke = nil
//        showPunchline = false
//        isLoading = true
//        errorMessage = nil
//
//        guard let url = URL(string: "https://official-joke-api.appspot.com/random_joke") else {
//            errorMessage = "Invalid joke URL."
//            isLoading = false
//            return
//        }
//
//        URLSession.shared.dataTask(with: url) { data, _, error in
//            DispatchQueue.main.async {
//                isLoading = false
//                if let data = data {
//                    if let decoded = try? JSONDecoder().decode(Joke.self, from: data) {
//                        joke = decoded
//                    } else {
//                        errorMessage = "Failed to decode joke."
//                    }
//                } else if let error = error {
//                    errorMessage = error.localizedDescription
//                } else {
//                    errorMessage = "Unknown error."
//                }
//            }
//        }.resume()
//    }
//}
//
//#Preview {
//    SOSRelaxView()
//}
