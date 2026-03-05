import SwiftUI
import UIKit

final class DataStore: ObservableObject {
    @Published var entries: [AngerEntry] = []

    init() {
        loadEntries()
    }

    func saveEntries() {
        do {
            let encodedData = try JSONEncoder().encode(entries)
            UserDefaults.standard.set(encodedData, forKey: "angerEntries")
            print("Entries saved successfully.")
        } catch {
            print("Error saving entries: \(error)")
        }
    }

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

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = scene.windows.first?.rootViewController {
            if let popover = activityViewController.popoverPresentationController {
                popover.sourceView = rootVC.view
                popover.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }

            rootVC.present(activityViewController, animated: true, completion: nil)
        }
    }
}
