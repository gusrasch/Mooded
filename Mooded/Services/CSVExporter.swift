import Foundation
import SwiftUI
import UniformTypeIdentifiers

class CSVExporter {
    static func export(moods: [Mood]) -> FileDocument {
        let csvString = "Date,Time,Rating\n" + moods.map { mood in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm:ss"
            
            return "\(dateFormatter.string(from: mood.timestamp)),\(timeFormatter.string(from: mood.timestamp)),\(mood.rating)"
        }.joined(separator: "\n")
        
        return TextFile(text: csvString)
    }
}

struct TextFile: FileDocument {
    static var readableContentTypes = [UTType.commaSeparatedText]
    var text: String

    init(text: String) {
        self.text = text
    }
    
    init(configuration: ReadConfiguration) throws {
        text = ""
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: text.data(using: .utf8)!)
    }
}
