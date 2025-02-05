import SwiftUI
import Charts

struct HistoryView: View {
    @ObservedObject var moodStore: MoodStore
    @ObservedObject var habitStore: HabitStore
    @State private var timeRange: TimeRange = .week
    
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
    
    private var filteredHabitCompletions: [(habit: Habit, completions: [HabitCompletion])] {
        habitStore.habits.map { habit in
            let completions = habitStore.completions.filter { completion in
                completion.habitId == habit.id &&
                completion.date >= getFilterDate()
            }
            return (habit, completions)
        }
    }
    
    private func getFilterDate() -> Date {
        let calendar = Calendar.current
        let date = calendar.startOfDay(for: Date())
        
        switch timeRange {
        case .week:
            return calendar.date(byAdding: .day, value: -7, to: date)!
        case .month:
            return calendar.date(byAdding: .month, value: -1, to: date)!
        case .year:
            return calendar.date(byAdding: .year, value: -1, to: date)!
        }
    }
    
    private var averageMood: Double {
        guard !filteredMoods.isEmpty else { return 0 }
        return Double(filteredMoods.map(\.rating).reduce(0, +)) / Double(filteredMoods.count)
    }
    
    private var habitCompletionRate: [String: Double] {
        var rates: [String: Double] = [:]
        let calendar = Calendar.current
        let totalDays = calendar.dateComponents([.day], from: getFilterDate(), to: Date()).day ?? 1
        
        for (habit, completions) in filteredHabitCompletions {
            let completionCount = completions.count
            rates[habit.name] = (Double(completionCount) / Double(totalDays)) * 100
        }
        return rates
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
    
    private func weatherIcon(for rating: Int) -> String {
        switch rating {
        case 1: return "cloud.heavyrain"
        case 2: return "cloud.drizzle"
        case 3: return "cloud"
        case 4: return "cloud.sun"
        case 5: return "sun.max"
        default: return "cloud"
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
                    
                    // Summary Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Summary")
                            .font(.headline)
                            .foregroundColor(.primary.opacity(0.8))
                        
                        HStack(spacing: 20) {
                            VStack(spacing: 4) {
                                Text("\(averageMood, specifier: "%.1f")")
                                    .font(.system(size: 24, weight: .bold))
                                Text("Avg Mood")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Divider()
                            
                            VStack(spacing: 4) {
                                Text("\(filteredMoods.count)")
                                    .font(.system(size: 24, weight: .bold))
                                Text("Check-ins")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        if !habitCompletionRate.isEmpty {
                            Divider()
                                .padding(.vertical, 8)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(habitCompletionRate.sorted(by: { $0.value > $1.value }), id: \.key) { habit, rate in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(habit)
                                            .font(.subheadline)
                                        
                                        GeometryReader { geometry in
                                            HStack(spacing: 0) {
                                                Rectangle()
                                                    .fill(Color.blue.opacity(0.3))
                                                    .frame(width: geometry.size.width * CGFloat(rate / 100))
                                                
                                                Text("\(Int(rate))%")
                                                    .font(.caption)
                                                    .padding(.leading, 8)
                                            }
                                        }
                                        .frame(height: 20)
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 10)
                    )
                    .padding(.horizontal)
                    
                    // Log Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Activity Log")
                            .font(.headline)
                            .foregroundColor(.primary.opacity(0.8))
                        
                        ForEach(filteredMoods.prefix(5)) { mood in
                            HStack {
                                HStack(spacing: 4) {
                                    Image(systemName: weatherIcon(for: mood.rating))
                                        .font(.system(size: 20))
                                    Text("\(mood.rating)")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .foregroundColor(moodColor(for: Double(mood.rating)))
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text(mood.timestamp, style: .date)
                                        .font(.subheadline)
                                    Text(mood.timestamp, style: .time)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        
                        ForEach(filteredHabitCompletions.flatMap { habit, completions in
                            completions.prefix(3).map { completion in
                                (habit.name, completion)
                            }
                        }, id: \.1.id) { habitName, completion in
                            HStack {
                                Text(habitName)
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text(completion.date, style: .date)
                                        .font(.subheadline)
                                    Text(completion.date, style: .time)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 8)
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
            .navigationTitle("History")
            .navigationBarItems(trailing: CSVExportButton(moods: moodStore.moods))
        }
    }
}
