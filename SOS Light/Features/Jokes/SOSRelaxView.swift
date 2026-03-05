import SwiftUI

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
        ZStack {
            LinearGradient(
                colors: [Color.black, Color(white: 0.08)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("SOS RELAX")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .tracking(2)
                    .foregroundColor(.white)

                ScrollView {
                    VStack(spacing: 12) {
                        if let joke = joke {
                            Text(joke.setup)
                                .font(.title3.weight(.semibold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal)

                            if showPunchline {
                                Text(joke.punchline)
                                    .font(.body.bold())
                                    .foregroundColor(.white.opacity(0.86))
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.horizontal)
                            } else {
                                Button("Show Answer") {
                                    showPunchline = true
                                }
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                        } else if isLoading {
                            ProgressView("Generating a joke...")
                                .tint(.white)
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                        } else if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal)
                        } else {
                            Text("Tap below to get a light-hearted joke.")
                                .foregroundColor(.white.opacity(0.86))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
                    .cornerRadius(16)
                }

                Button("Tell me a Joke") {
                    Task {
                        await fetchJokeIfAllowed()
                    }
                }
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(14)
                .disabled(isLoading)

                Text("In emergencies, try to stay calm, cool, and relaxed. Don’t panic.")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                if subscriptionManager.isSubscribed {
                    Text("You are recognized as an SOS Light Supporter. Thank you.")
                        .foregroundColor(.white.opacity(0.9))
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                }

                Button(action: {
                    showingSheet = true
                }) {
                    Text("Love SOS Light?")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                        )
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical)
        }
        .sheet(isPresented: $showingSheet) {
            SOSRelaxSubscriptionView(isPresented: $showingSheet, showingLegalInfo: $showingLegalInfo)
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

    private func fetchJokeIfAllowed() async {
        if subscriptionManager.isSubscribed || canFetchJoke() {
            incrementJokeCount()
            await fetchJoke()
        } else {
            showUpgradeAlert = true
        }
    }

    private func fetchJoke() async {
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

    private func canFetchJoke() -> Bool {
        resetIfNewDay()
        return getJokeCountToday() < dailyLimit
    }

    private func getJokeCountToday() -> Int {
        UserDefaults.standard.integer(forKey: jokeCountKey)
    }

    private func incrementJokeCount() {
        let count = getJokeCountToday() + 1
        UserDefaults.standard.set(count, forKey: jokeCountKey)
        UserDefaults.standard.set(Date(), forKey: lastUsedDateKey)
    }

    private func resetIfNewDay() {
        guard let lastUsed = UserDefaults.standard.object(forKey: lastUsedDateKey) as? Date else {
            return
        }

        if !Calendar.current.isDateInToday(lastUsed) {
            UserDefaults.standard.set(0, forKey: jokeCountKey)
        }
    }
}

#Preview {
    SOSRelaxView()
}
