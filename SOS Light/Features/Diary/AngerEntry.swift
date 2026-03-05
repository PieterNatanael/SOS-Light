import Foundation

struct AngerEntry: Identifiable, Codable {
    var id: UUID
    let date: Date
    var text: String
    var angerLevel: String

    init(id: UUID = UUID(), date: Date, text: String, angerLevel: String) {
        self.id = id
        self.date = date
        self.text = text
        self.angerLevel = angerLevel
    }
}
