//
//  DiaryView.swift
//  SOS Light
//
//  Created by Pieter Yoshua Natanael on 02/12/24.
//

import SwiftUI
import UIKit

// MARK: - Data Model for Anger Entry

/// Represents an anger entry with date, text, and anger level.
struct AngerEntry: Identifiable, Codable {
    var id: UUID
    let date: Date
    var text: String
    var angerLevel: String // Can be "Low", "Medium", or "High"
    
    init(id: UUID = UUID(), date: Date, text: String, angerLevel: String) {
        self.id = id
        self.date = date
        self.text = text
        self.angerLevel = angerLevel
    }
}


// MARK: - Main App View


struct AngryKidApp: App {
    @StateObject var dataStore = DataStore()
   
    var body: some Scene {
        WindowGroup {
            DiaryView(dataStore: dataStore)
        }
    }
}

// MARK: - Data Store for Managing Persistence

/// Manages the storage and retrieval of anger entries.
class DataStore: ObservableObject {
    @Published var entries: [AngerEntry] = []
    
    init() {
        loadEntries()
    }
    
    /// Saves the current list of anger entries to UserDefaults.
    func saveEntries() {
        do {
            let encodedData = try JSONEncoder().encode(entries)
            UserDefaults.standard.set(encodedData, forKey: "angerEntries")
            print("Entries saved successfully.")
        } catch {
            print("Error saving entries: \(error)")
        }
    }
    
    /// Loads the list of anger entries from UserDefaults.
    func loadEntries() {
        if let encodedData = UserDefaults.standard.data(forKey: "angerEntries") {
            do {
                let savedEntries = try JSONDecoder().decode([AngerEntry].self, from: encodedData)
                entries = savedEntries
                print("Entries loaded successfully.")
            } catch {
                print("Error loading entries: \(error)")
            }
        }
    }
    
    /// Exports all anger entries as a formatted string.
    func exportAllEntries() {
        var exportString = "Export From SOS Diary\n\n"
        exportString += entries.map { entry -> String in
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            let formattedDate = dateFormatter.string(from: entry.date)
            return "\(formattedDate) - \(entry.text) - Priority Level: \(entry.angerLevel)"
        }.joined(separator: "\n")
        
        let activityViewController = UIActivityViewController(activityItems: [exportString], applicationActivities: nil)
        
        UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
}

// MARK: - Main Content View

struct DiaryView: View {
    @ObservedObject var dataStore: DataStore
    @State private var newText: String = ""
    @State private var selectedAngerLevel: String = "Low"
    @State private var showAdsAndAppFunctionality = false
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(colors: [Color(#colorLiteral(red: 0.5738074183, green: 0.5655357838, blue: 0, alpha: 1)), .clear], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        showAdsAndAppFunctionality = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color.white)
                            .padding()
                            .shadow(color: Color.black.opacity(0.6), radius: 5, x: 0, y: 2)
                    }
                }
                
                Text("SOS Diary")
                    .font(.title.bold())
                    .padding()
                
                TextField("Write down your SOS diary here...", text: $newText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Picker(selection: $selectedAngerLevel, label: Text("Priority Level")) {
                    Text("Low").tag("Low")
                    Text("Medium").tag("Medium")
                    Text("High").tag("High")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                Button(action: {
                    saveEntry()
                    dataStore.saveEntries()
                }) {
                    Text("New Entry")
                        .font(.title2)
                        .padding()
                }
                .frame(width: 233)
                .background(Color(#colorLiteral(red: 0.4500938654, green: 0.9813225865, blue: 0.4743030667, alpha: 1)))
                .cornerRadius(25)
                .foregroundColor(.black)
                .padding()
                .shadow(color: Color.black.opacity(0.5), radius: 5, x: 0, y: 2)
                
                Button(action: {
                    dataStore.exportAllEntries()
                }) {
                    Text("Export All")
                        .font(.title2)
                        .padding()
                }
                .frame(width: 233)
                .background(Color.white)
                .cornerRadius(25)
                .foregroundColor(.black)
                .padding()
                .shadow(color: Color.black.opacity(0.5), radius: 5, x: 0, y: 2)
                
                List {
                    ForEach(dataStore.entries) { entry in
                        VStack(alignment: .leading) {
                            Text("\(entry.date, formatter: dateFormatter)")
                                .font(.headline)
                            Text(entry.text)
                                .font(.body)
                                .foregroundColor(Color.gray)
                            Text("Priority Level: \(entry.angerLevel)")
                                .font(.caption)
                                .foregroundColor(Color.red)
                        }
                    }
                    .onDelete { indexSet in
                        deleteEntry(at: indexSet)
                        dataStore.saveEntries()
                    }
                }
            }
            .sheet(isPresented: $showAdsAndAppFunctionality) {
                ShowExplainView(onConfirm: {
                    showAdsAndAppFunctionality = false
                })
            }
            .padding()
            .onDisappear {
                dataStore.saveEntries()
            }
        }
    }
    
    /// Saves a new anger entry to the data store.
    func saveEntry() {
        guard !newText.isEmpty else { return }
        let newEntry = AngerEntry(date: Date(), text: newText, angerLevel: selectedAngerLevel)
        dataStore.entries.append(newEntry)
        newText = ""
    }
    
    /// Deletes an anger entry from the data store.
    func deleteEntry(at offsets: IndexSet) {
        dataStore.entries.remove(atOffsets: offsets)
    }
    
    /// Date formatter for displaying dates.
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

// MARK: - Preview

struct DiaryView_Previews: PreviewProvider {
    static var previews: some View {
        DiaryView(dataStore: DataStore())
    }
}

// MARK: - Ads and App functionality

/// View that show ads and the app's functionality
struct ShowExplainView: View {
    var onConfirm: () -> Void

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Ads & App Functionality")
                        .font(.title3.bold())
                    Spacer()
                }
                Divider().background(Color.gray)
                
                // Ads Section
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
                    // Ads App Cards
                    VStack {
                        Divider().background(Color.gray)
                        CardView(imageName: "takemedication", appName: "Take Medication", appDescription: "Just press any of the 24 buttons, each representing an hour of the day, and you'll get timely reminders to take your medication. It's easy, quick, and ensures you never miss a dose!", appURL: "https://apps.apple.com/id/app/take-medication/id6736924598")
                        
                        Divider().background(Color.gray)

                        CardView(imageName: "BST", appName: "Blink Screen Time", appDescription: "Using screens can reduce your blink rate to just 6 blinks per minute, leading to dry eyes and eye strain. Our app helps you maintain a healthy blink rate to prevent these issues and keep your eyes comfortable.", appURL: "https://apps.apple.com/id/app/blink-screen-time/id6587551095")
                        Divider().background(Color.gray)
//                        CardView(imageName: "timetell", appName: "TimeTell", appDescription: "Announce the time every 30 seconds, no more guessing and checking your watch, for time-sensitive tasks.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
//                        Divider().background(Color.gray)
//                        CardView(imageName: "SingLoop", appName: "Sing LOOP", appDescription: "Record your voice effortlessly, and play it back in a loop.", appURL: "https://apps.apple.com/id/app/sing-l00p/id6480459464")
//                        Divider().background(Color.gray)
                        CardView(imageName: "hemorrhoid", appName: "Hemorrhoid", appDescription: " Ideal for individuals who experience hemorrhoids due to prolonged sitting or wish to prevent recurrence after previous episodes.", appURL: "https://apps.apple.com/app/hemorrhoid/id6738301292")
                        Divider().background(Color.gray)
//                        CardView(imageName: "insomnia", appName: "Insomnia Sheep", appDescription: "Design to ease your mind and help you relax leading up to sleep.", appURL: "https://apps.apple.com/id/app/insomnia-sheep/id6479727431")
//                        Divider().background(Color.gray)
//                        CardView(imageName: "dryeye", appName: "Dry Eye Read", appDescription: "Read content on screen easily and comfortably without stressing your eyes.", appURL: "https://apps.apple.com/id/app/dry-eye-read/id6449525064")
//                        Divider().background(Color.gray)
                       
                    }
                }
                Divider().background(Color.gray)
                Spacer()
            }
            
            HStack {
                Text("App Functionality")
                    .font(.title.bold())
                Spacer()
            }

            Text("""
            SOS Diary Features
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
            Where are the coordinates? Copy them directly from the built-in compass feature.
            Once done, click the "New Entry" button to save the details.
            Whether it's a small concern or a serious emergency, SOS Diary helps you stay organized and prepared.

            Automatic Saving

            Every entry is automatically saved with the current date and time, ensuring you can review past situations and track patterns effortlessly.

            Sharing Entries

            When connected to the internet, share your entries with trusted contacts for support or advice.

            Use the "Export" button to send your entry via chat or email, providing necessary context and details to those who can help.
            
            Privacy First

            Your SOS Diary entries remain securely stored on your device—nothing is collected or uploaded.
            We prioritize your privacy, offering a confidential and secure way to manage and reflect on your SOS situations.
            
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
            
            Button("Close") {
                onConfirm()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .font(.title3.bold())
            .cornerRadius(10)
            .padding()
            .shadow(color: Color.white.opacity(12), radius: 3, x: 3, y: 3)
                    
        }
        .padding()
    }
}

/// Custom view for displaying an app card.
struct CardView: View {
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
                Text(appDescription)
                    .font(.body)
                    .foregroundColor(.primary)
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
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 4)
    }
}
