import Foundation
import SwiftUI

class CSVExporter {
    static func createCSVFile(moods: [Mood]) throws -> URL {
        let csvString = "Date,Time,Rating\n" + moods.map { mood in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm:ss"
            
            return "\(dateFormatter.string(from: mood.timestamp)),\(timeFormatter.string(from: mood.timestamp)),\(mood.rating)"
        }.joined(separator: "\n")
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent("MoodHistory.csv")
        try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }
}

struct CSVExportButton: View {
    let moods: [Mood]
    
    var body: some View {
        Button(action: {
            do {
                let fileURL = try CSVExporter.createCSVFile(moods: moods)
                let activityVC = UIActivityViewController(
                    activityItems: [fileURL],
                    applicationActivities: nil
                )
                
                // Get the root view controller using the current window scene
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootVC = window.rootViewController {
                    rootVC.present(activityVC, animated: true)
                }
                
            } catch {
                print("Export failed: \(error.localizedDescription)")
            }
        }) {
            Image(systemName: "square.and.arrow.up")
        }
    }
}
