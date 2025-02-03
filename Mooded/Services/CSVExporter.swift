import Foundation
import SwiftUI
import UniformTypeIdentifiers

class CSVExporter {
    static func export(moods: [Mood]) -> String {
        let csvString = "Date,Time,Rating\n" + moods.map { mood in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm:ss"
            
            return "\(dateFormatter.string(from: mood.timestamp)),\(timeFormatter.string(from: mood.timestamp)),\(mood.rating)"
        }.joined(separator: "\n")
        
        return csvString
    }
}
