import SwiftUI

struct DiaryInfoSheetView: View {
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
                        Text("SOS DIARY INFO")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .tracking(1.5)
                            .foregroundColor(.white)
                        Spacer()
                    }

                    HStack {
                        Text("Apps")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                        Spacer()
                    }

                    VStack(spacing: 8) {
                        DiaryPromoCardView(imageName: "takemedication", appName: "Take Medication", appDescription: "Just press any of the 24 buttons.It's easy, quick, and ensures you never miss a dose!and with a built in medication tracker", appURL: "https://apps.apple.com/id/app/take-medication/id6736924598")
                        DiaryPromoCardView(imageName: "BST", appName: "Blink Screen Time", appDescription: "Using screens can reduce your blink rate to just 6 blinks per minute, leading to dry eyes and eye strain. Our app helps you maintain a healthy blink rate to prevent these issues and keep your eyes comfortable.", appURL: "https://apps.apple.com/id/app/blink-screen-time/id6587551095")
                        DiaryPromoCardView(imageName: "insomnia", appName: "Insomnia Sheep", appDescription: "Made to calm your mind and help you relax before sleep. Includes sleep hypnosis and a sleep tracker to support better rest.", appURL: "https://apps.apple.com/id/app/insomnia-sheep/id6479727431")
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

                    Text("""
                    SOS Notes Features
                    Log Your SOS Situations

                    Quickly Record Situations:
                    Write down details about events or emergencies as they occur.
                    Set Priority Levels:
                    Choose a priority level that reflects the severity of your situation:
                    Low: Minor issues or concerns.
                    Medium: Situations requiring attention but still manageable.
                    High: Critical or emergency scenarios.
                    Add Situation Details:
                    Include specific information such as:
                    What happened?
                    What actions were taken?
                    Where are the locations? Copy them directly from the built-in compass feature.
                    Once done, click the "New Entry" button to save the details.
                    Whether it's a small concern or a serious emergency, SOS Notes helps you stay organized and prepared.

                    Automatic Saving

                    Every entry is automatically saved with the current date and time, ensuring you can review past situations and track patterns effortlessly.

                    Sharing Entries

                    When connected to the internet, share your entries with trusted contacts for support or advice.

                    Use the "Export" button to send your entry via chat or email, providing necessary context and details to those who can help.

                    Privacy First

                    Your SOS Notes entries remain securely stored on your device-nothing is collected or uploaded.
                    We prioritize your privacy, offering a confidential and secure way to manage and reflect on your SOS situations.
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

                    Text("Love SOS Light? Open SOS Relax to learn more.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.86))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button("Close") {
                        onConfirm()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)
                    .font(.headline.bold())
                    .cornerRadius(12)
                }
                .padding()
            }
        }
    }
}

struct DiaryPromoCardView: View {
    let imageName: String
    let appName: String
    let appDescription: String
    let appURL: String

    var body: some View {
        HStack {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 70, height: 70)
                .cornerRadius(8)
                .clipped()
            VStack(alignment: .leading) {
                Text(appName)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(appDescription)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.82))
            }
            Spacer()
            Button(action: {
                if let url = URL(string: appURL) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Get")
                    .font(.subheadline)
                    .padding(8)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(8)
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
