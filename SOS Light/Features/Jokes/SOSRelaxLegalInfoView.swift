import SwiftUI

struct SOSRelaxLegalInfoView: View {
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color(white: 0.08)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 14) {
                Text("PRIVACY & TERMS")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .tracking(1.5)
                    .foregroundColor(.white)

                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Privacy Policy")
                            .font(.title3.bold())
                            .foregroundColor(.white)

                        Text("""
                        SOS Light does not collect, store, or track any personal information. All your data stays on your device. Your subscription is securely managed via your Apple ID and App Store account.
                        """)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.86))

                        Text("Terms of Use (EULA)")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .padding(.top, 4)

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
                        .foregroundColor(.white.opacity(0.86))
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
                    .cornerRadius(12)
                }

                Button("Close") {
                    isPresented = false
                }
                .font(.headline.bold())
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(12)
            }
            .padding()
        }
    }
}
