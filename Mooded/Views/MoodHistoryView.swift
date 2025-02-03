import SwiftUI

struct MoodHistoryView: View {
    @ObservedObject var moodStore: MoodStore
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(moodStore.moods.reversed()) { mood in
                    HStack {
                        Text("\(dateFormatter.string(from: mood.timestamp))")
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("\(mood.rating)")
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            .navigationTitle("Mood History")
            .navigationBarItems(trailing: 
                ShareLink(
                    item: CSVExporter.export(moods: moodStore.moods),
                    preview: SharePreview("Mood History.csv")
                )
            )
        }
    }
}
