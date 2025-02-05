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
        case all = "All Time"
    }
    
    // Combined type to represent any activity
    enum Activity: Identifiable {
        case mood(Mood)
        case habitCompletion(habit: Habit, completion: HabitCompletion)
        
        var id: String {
            switch self {
            case .mood(let mood): return "mood-\(mood.id)"
            case .habitCompletion(_, let completion): return "habit-\(completion.id)"
            }
        }
        
        var timestamp: Date {
            switch self {
            case .mood(let mood): return mood.timestamp
            case .habitCompletion(_, let completion): return completion.date
            }
        }
    }
    
    private var filteredActivities: [Activity] {
        let filterDate = getFilterDate()
        
        // Convert moods to activities
        let moodActivities = moodStore.moods
            .filter { $0.timestamp >= filterDate }
            .map { Activity.mood($0) }
        
        // Convert habit completions to activities
        let habitActivities = habitStore.habits.flatMap { habit in
            habitStore.completions
                .filter { $0.habitId == habit.id && $0.date >= filterDate }
                .map { Activity.habitCompletion(habit: habit, completion: $0) }
        }
        
        // Combine and sort all activities
        return (moodActivities + habitActivities)
            .sorted { $0.timestamp > $1.timestamp }
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
        case .all:
            return Date.distantPast
        }
    }
    
    private var filteredMoods: [Mood] {
        moodStore.moods.filter { $0.timestamp >= getFilterDate() }
    }
    
    private var averageMood: Double {
        guard !filteredMoods.isEmpty else { return 0 }
        return Double(filteredMoods.map(\.rating).reduce(0, +)) / Double(filteredMoods.count)
    }
    
    private var habitCompletionRate: [String: Double] {
        var rates: [String: Double] = [:]
        let calendar = Calendar.current
        let totalDays = max(1, calendar.dateComponents([.day], from: getFilterDate(), to: Date()).day ?? 1)
        
        for habit in habitStore.habits {
            let completions = habitStore.completions.filter {
                $0.habitId == habit.id && $0.date >= getFilterDate()
            }
            rates[habit.name] = (Double(completions.count) / Double(totalDays)) * 100
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
                    
                    // Activity Log
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Activity Log")
                            .font(.headline)
                            .foregroundColor(.primary.opacity(0.8))
                        
                        LazyVStack(spacing: 8, pinnedViews: []) {
                            ForEach(filteredActivities) { activity in
                                HStack {
                                    switch activity {
                                    case .mood(let mood):
                                        HStack(spacing: 4) {
                                            Image(systemName: weatherIcon(for: mood.rating))
                                                .font(.system(size: 20))
                                            Text("\(mood.rating)")
                                                .font(.system(size: 16, weight: .medium))
                                        }
                                        .foregroundColor(moodColor(for: Double(mood.rating)))
                                        
                                    case .habitCompletion(let habit, _):
                                        HStack(spacing: 4) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 20))
                                                .foregroundColor(.green)
                                            Text(habit.name)
                                                .font(.subheadline)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing) {
                                        Text(activity.timestamp, style: .date)
                                            .font(.subheadline)
                                        Text(activity.timestamp, style: .time)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.vertical, 8)
                                
                                Divider()
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
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("History")
            .navigationBarItems(trailing: CSVExportButton(moods: moodStore.moods))
        }
    }
}
