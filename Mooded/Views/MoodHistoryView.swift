import SwiftUI
import Charts

struct MoodHistoryView: View {
    @ObservedObject var moodStore: MoodStore
    @State private var showingExportSheet = false
    
    var body: some View {
        VStack {
            if moodStore.moods.isEmpty {
                Text("No mood entries yet")
                    .foregroundColor(.secondary)
            } else {
                Chart(moodStore.moods) { mood in
                    LineMark(
                        x: .value("Time", mood.timestamp),
                        y: .value("Mood", mood.rating)
                    )
                }
                .frame(height: 300)
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 5))
                }
                .chartYAxis {
                    AxisMarks(values: [1, 2, 3, 4, 5])
                }
                .padding()
            }
            
            Spacer()
        }
        .navigationTitle("Mood History")
        .navigationBarItems(
            trailing: Button(action: {
                showingExportSheet = true
            }) {
                Image(systemName: "square.and.arrow.up")
            }
        )
        .fileExporter(
            isPresented: $showingExportSheet,
            document: CSVExporter.export(moods: moodStore.moods),
            contentType: .commaSeparatedText,
            defaultFilename: "mood_history.csv"
        ) { result in
            if case .failure(let error) = result {
                print("Export failed: \(error.localizedDescription)")
            }
        }
    }
}
