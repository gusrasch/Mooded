import Foundation

struct Mood: Identifiable, Codable {
    let id: UUID
    let rating: Int
    let timestamp: Date
    
    init(rating: Int, timestamp: Date = Date()) {
        self.id = UUID()
        self.rating = rating
        self.timestamp = timestamp
    }
}
