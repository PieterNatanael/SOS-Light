import SwiftUI
import StoreKit

struct SOSRelaxSubscriptionView: View {
    @Binding var isPresented: Bool
    @Binding var showingLegalInfo: Bool

    @StateObject private var subscriptionManager = SubscriptionManager.shared

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
                    Text("SUPPORT SOS LIGHT")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .tracking(1.6)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)

                    Text("""
                    Our mission with SOS Light is to be a trusted helper in emergencies, bringing key tools into one app to keep people safe, visible, and supported when it matters most.
                    """)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.86))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)

                    if subscriptionManager.isLoading {
                        ProgressView("Loading...")
                            .tint(.white)
                            .foregroundColor(.white)
                    } else if let errorMessage = subscriptionManager.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                    }

                    if !subscriptionManager.products.isEmpty, let product = subscriptionManager.products.first {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("SOS Light Full Version: Unlimited SOS Relax jokes")
                                .font(.headline)
                                .foregroundColor(.white)

                            Text("Removes the 3 jokes per day limit.")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))

                            Text("Free: up to 3 jokes per day")
                                .font(.footnote)
                                .foregroundColor(.white.opacity(0.75))

                            Text("Full Version: unlimited jokes")
                                .font(.footnote)
                                .foregroundColor(.white.opacity(0.75))

                            Text("\(product.displayPrice) per year")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.top, 6)

                            Text("Auto-renews yearly unless cancelled at least 24 hours before renewal.")
                                .font(.footnote)
                                .foregroundColor(.white.opacity(0.7))
                                .fixedSize(horizontal: false, vertical: true)

                            Text("Payment will be charged to your Apple ID. Manage or cancel anytime in App Store Settings.")
                                .font(.footnote)
                                .foregroundColor(.white.opacity(0.7))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.25), lineWidth: 1)
                        )
                        .cornerRadius(12)
                    } else {
                        Text("Full Version to stay ready in emergency.")
                            .foregroundColor(.white.opacity(0.86))
                            .multilineTextAlignment(.center)
                    }

                    Button(action: {
                        Task {
                            await subscriptionManager.purchase()
                        }
                    }) {
                        Text(subscriptionManager.isSubscribed ? "Subscribed" : "Subscribe")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(subscriptionManager.isSubscribed ? Color.white.opacity(0.35) : Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(12)
                    }
                    .disabled(subscriptionManager.isSubscribed || subscriptionManager.isLoading)

                    Button("Restore Purchase") {
                        Task {
                            await subscriptionManager.restorePurchases()
                        }
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.clear)
                    .foregroundColor(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                    )
                    .cornerRadius(12)
                    .disabled(subscriptionManager.isLoading)

                    Button("Privacy Policy & Terms of Use") {
                        showingLegalInfo = true
                    }
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))

                    Button("Rate on App Store") {
                        if let url = URL(string: "https://apps.apple.com/app/6504213303?action=write-review") {
                            UIApplication.shared.open(url)
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))

                    Button("Close") {
                        isPresented = false
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.clear)
                    .foregroundColor(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
                    .cornerRadius(12)
                }
                .padding(.horizontal, 18)
                .padding(.vertical)
            }
        }
        .sheet(isPresented: $showingLegalInfo) {
            SOSRelaxLegalInfoView(isPresented: $showingLegalInfo)
        }
    }
}

func priceText(from priceString: String) -> String {
    let symbol = priceString.trimmingCharacters(in: .whitespaces).prefix { !$0.isNumber && $0 != "." }
    let numberString = priceString.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)

    if let value = Double(numberString) {
        return "\(symbol)\(String(format: "%.2f", value * 8))"
    }

    return "Invalid Price"
}
