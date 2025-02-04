import SwiftUI
import Charts

struct MoodHistoryView: View {
    @ObservedObject var moodStore: MoodStore
    @State private var timeRange: TimeRange = .week
    @State private var selectedMood: Mood?
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    private var filteredMoods: [Mood] {
        let calendar = Calendar.current
        let date = calendar.startOfDay(for: Date())
        let filterDate: Date
        
        switch timeRange {
        case .week:
            filterDate = calendar.date(byAdding: .day, value: -7, to: date)!
        case .month:
            filterDate = calendar.date(byAdding: .month, value: -1, to: date)!
        case .year:
            filterDate = calendar.date(byAdding: .year, value: -1, to: date)!
        }
        
        return moodStore.moods.filter { $0.timestamp >= filterDate }
    }
    
    private var averageMood: Double {
        guard !filteredMoods.isEmpty else { return 0 }
        return Double(filteredMoods.map(\.rating).reduce(0, +)) / Double(filteredMoods.count)
    }
    
    private var moodsByDay: [(date: Date, average: Double)] {
        let calendar = Calendar.current
        let groupedMoods = Dictionary(grouping: filteredMoods) { mood in
            calendar.startOfDay(for: mood.timestamp)
        }
        
        return groupedMoods.map { date, moods in
            let average = Double(moods.map(\.rating).reduce(0, +)) / Double(moods.count)
            return (date, average)
        }.sorted { $0.date < $1.date }
    }
    
    private func moodColor(for rating: Double) -> Color {
        switch rating {
        case ..<1.5: return .indigo.opacity(0.8)
        case ..<2.5: return .blue.opacity(0.5)
        case ..<3.5: return .gray.opacity(0.8)
        case ..<4.5: return .yellow.opacity(0.8)
        default: return .orange.opacity(0.8)
        }
    }
    
    private func weatherIcon(for rating: Double) -> String {
        switch rating {
        case ..<1.5: return "cloud.heavyrain"
        case ..<2.5: return "cloud.drizzle"
        case ..<3.5: return "cloud"
        case ..<4.5: return "cloud.sun"
        default: return "sun.max"
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Time Range Picker
                    Picker("Time Range", selection: $timeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Weather Summary Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Weather Summary")
                            .font(.headline)
                            .foregroundColor(.primary.opacity(0.8))
                        
                        HStack {
                            Image(systemName: weatherIcon(for: averageMood))
                                .font(.system(size: 40))
                                .foregroundColor(moodColor(for: averageMood))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Average: \(averageMood, specifier: "%.1f")")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                                Text("\(filteredMoods.count) recordings")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 10)
                    )
                    .padding(.horizontal)
                    
                    // Mood Chart
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Weather Patterns")
                            .font(.headline)
                            .foregroundColor(.primary.opacity(0.8))
                        
                        if #available(iOS 16.0, *) {
                            Chart(moodsByDay, id: \.date) { day in
                                LineMark(
                                    x: .value("Date", day.date),
                                    y: .value("Mood", day.average)
                                )
                                .foregroundStyle(moodColor(for: day.average))
                                
                                AreaMark(
                                    x: .value("Date", day.date),
                                    y: .value("Mood", day.average)
                                )
                                .foregroundStyle(
                                    .linearGradient(
                                        colors: [moodColor(for: day.average).opacity(0.2), .clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                            }
                            .chartYScale(domain: 1...5)
                            .chartYAxis {
                                AxisMarks(values: [1, 2, 3, 4, 5])
                            }
                            .frame(height: 200)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 10)
                    )
                    .padding(.horizontal)
                    
                    // Daily Breakdown
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Daily Weather Log")
                            .font(.headline)
                            .foregroundColor(.primary.opacity(0.8))
                        
                        ForEach(moodsByDay.reversed().prefix(5), id: \.date) { day in
                            HStack {
                                Image(systemName: weatherIcon(for: day.average))
                                    .foregroundColor(moodColor(for: day.average))
                                    .font(.system(size: 20))
                                
                                Text(day.date, style: .date)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("\(day.average, specifier: "%.1f")")
                                    .fontWeight(.semibold)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.03), radius: 5)
                            )
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 10)
                    )
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Weather History")
            .navigationBarItems(trailing:
                ShareLink(
                    item: CSVExporter.export(moods: moodStore.moods),
                    preview: SharePreview("Mood History.csv")
                )
            )
        }
    }
}
