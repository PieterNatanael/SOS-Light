//
//  DiaryView.swift
//  SOS Light
//
//  Created by Pieter Yoshua Natanael on 02/12/24.
//
//DiaryView

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
    
    //trigger crash on Ipad but not on iPhone
    /// Exports all anger entries as a formatted string.
//    func exportAllEntries() {
//        var exportString = "Export From SOS Notes\n\n"
//        exportString += entries.map { entry -> String in
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateStyle = .medium
//            dateFormatter.timeStyle = .short
//            let formattedDate = dateFormatter.string(from: entry.date)
//            return "\(formattedDate) - \(entry.text) - Priority Level: \(entry.angerLevel)"
//        }.joined(separator: "\n")
//        
//        let activityViewController = UIActivityViewController(activityItems: [exportString], applicationActivities: nil)
//        
//        UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
//    }
//    
   
    
    func exportAllEntries() {
        var exportString = "Export From SOS Notes\n\n"
        exportString += entries.map { entry -> String in
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            let formattedDate = dateFormatter.string(from: entry.date)
            return "\(formattedDate) - \(entry.text) - Priority Level: \(entry.angerLevel)"
        }.joined(separator: "\n")

        let activityViewController = UIActivityViewController(activityItems: [exportString], applicationActivities: nil)

        // Safely get the root view controller
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = scene.windows.first?.rootViewController {

            // For iPad: set sourceView for popover
            if let popover = activityViewController.popoverPresentationController {
                popover.sourceView = rootVC.view
                popover.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }

            rootVC.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    
}

// MARK: - Main Content View

struct DiaryView: View {
    @ObservedObject var dataStore: DataStore
    @State private var newText: String = ""
    @State private var selectedAngerLevel: String = "Low"
    @State private var showAdsAndAppFunctionality = false
    @FocusState private var isEditorFocused: Bool
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color(white: 0.08)],
                startPoint: .top,
                endPoint: .bottom
            )
                .ignoresSafeArea()
            
            VStack(spacing: 14) {
                HStack {
                    Text("SOS DIARY")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .tracking(1.8)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        showAdsAndAppFunctionality = true
                    }) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(Color.white)
                            .padding(10)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.45), lineWidth: 1)
                            )
                    }
                }

                ZStack(alignment: .topLeading) {
                    if newText.isEmpty {
                        Text("Write down your SOS Notes here...")
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                    }

                    TextEditor(text: $newText)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .frame(minHeight: 96, maxHeight: 140)
                        .focused($isEditorFocused)
                        .background(Color.clear)
                }
                .background(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
                .cornerRadius(12)

                Picker(selection: $selectedAngerLevel, label: Text("Priority Level")) {
                    Text("Low").tag("Low")
                    Text("Medium").tag("Medium")
                    Text("High").tag("High")
                }
                .pickerStyle(SegmentedPickerStyle())
                .colorScheme(.dark)
                
                HStack(spacing: 10) {
                    Button(action: {
                        isEditorFocused = false
                        saveEntry()
                        dataStore.saveEntries()
                    }) {
                        Text("New Entry")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        dataStore.exportAllEntries()
                    }) {
                        Text("Export All")
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
                    }
                }
                
                List {
                    ForEach(dataStore.entries) { entry in
                        VStack(alignment: .leading) {
                            Text("\(entry.date, formatter: dateFormatter)")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text(entry.text)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.86))
                            Text("Priority Level: \(entry.angerLevel)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.75))
                        }
                        .listRowBackground(Color.white.opacity(0.06))
                    }
                    .onDelete { indexSet in
                        deleteEntry(at: indexSet)
                        dataStore.saveEntries()
                    }
                }
                .listStyle(.plain)
                .background(Color.clear)
            }
            .sheet(isPresented: $showAdsAndAppFunctionality) {
                ShowExplainView(onConfirm: {
                    showAdsAndAppFunctionality = false
                })
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isEditorFocused = false
                    }
                }
            }
            .onTapGesture {
                isEditorFocused = false
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
                        CardView(imageName: "takemedication", appName: "Take Medication", appDescription: "Just press any of the 24 buttons.It's easy, quick, and ensures you never miss a dose!and with a built in medication tracker", appURL: "https://apps.apple.com/id/app/take-medication/id6736924598")
                        CardView(imageName: "BST", appName: "Blink Screen Time", appDescription: "Using screens can reduce your blink rate to just 6 blinks per minute, leading to dry eyes and eye strain. Our app helps you maintain a healthy blink rate to prevent these issues and keep your eyes comfortable.", appURL: "https://apps.apple.com/id/app/blink-screen-time/id6587551095")
                        CardView(imageName: "insomnia", appName: "Insomnia Sheep", appDescription: "Made to calm your mind and help you relax before sleep. Includes sleep hypnosis and a sleep tracker to support better rest.", appURL: "https://apps.apple.com/id/app/insomnia-sheep/id6479727431")
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

                    Your SOS Notes entries remain securely stored on your device—nothing is collected or uploaded.
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
