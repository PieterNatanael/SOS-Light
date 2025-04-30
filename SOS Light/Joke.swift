//
//  Joke.swift
//  SOS Light
//
//  Created by Pieter Yoshua Natanael on 30/04/25.
//

//I want to use Async and Await here

import SwiftUI

struct Joke: Decodable {
    let setup: String
    let punchline: String
}

struct SOSRelaxView: View {
    @State private var joke: Joke?
    @State private var showPunchline = false
    @State private var isLoading = false
    @State private var errorMessage: String?

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
                fetchJoke()
            }
            .font(.title)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(#colorLiteral(red: 0.4500938654, green: 0.9813225865, blue: 0.4743030667, alpha: 1)))
            .foregroundColor(.black)
            .cornerRadius(10)

            Spacer()

            Text("In emergencies, try to stay calm, cool, and relaxed. Don’t panic.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
    }

    func fetchJoke() {
        joke = nil
        showPunchline = false
        isLoading = true
        errorMessage = nil

        guard let url = URL(string: "https://official-joke-api.appspot.com/random_joke") else {
            errorMessage = "Invalid joke URL."
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                isLoading = false
                if let data = data {
                    if let decoded = try? JSONDecoder().decode(Joke.self, from: data) {
                        joke = decoded
                    } else {
                        errorMessage = "Failed to decode joke."
                    }
                } else if let error = error {
                    errorMessage = error.localizedDescription
                } else {
                    errorMessage = "Unknown error."
                }
            }
        }.resume()
    }
}

#Preview {
    SOSRelaxView()
}
