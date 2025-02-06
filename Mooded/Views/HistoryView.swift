import SwiftUI
import Charts

struct HistoryView: View {
    @ObservedObject var moodStore: MoodStore
    @ObservedObject var habitStore: HabitStore
    @State private var timeRange: TimeRange = .week
    @State private var selectedHabit: Habit?
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
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
    
    // Data point for trend visualization
    struct TrendPoint: Identifiable {
        let id = UUID()
        let date: Date
        let moodRating: Double
        let habitCompletions: Int
        let totalHabits: Int
    }
    
    private var trendData: [TrendPoint] {
        let calendar = Calendar.current
        let startDate = getFilterDate()
        let endDate = Date()
        
        // For year view, aggregate by month
        if timeRange == .year {
            var points: [TrendPoint] = []
            var currentDate = startDate
            
            while currentDate <= endDate {
                let monthStart = calendar.startOfDay(for: currentDate)
                guard let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) else { break }
                
                // Get moods for the month
                let monthMoods = moodStore.moods.filter { mood in
                    (monthStart...monthEnd).contains(mood.timestamp)
                }
                
                let averageMood = monthMoods.isEmpty ? 0 :
                    Double(monthMoods.map(\.rating).reduce(0, +)) / Double(monthMoods.count)
                
                // Get habit completions for the month
                let completions = habitStore.completions.filter { completion in
                    (monthStart...monthEnd).contains(completion.date)
                }
                
                // Calculate average daily completions for the month
                let daysInMonth = calendar.dateComponents([.day], from: monthStart, to: min(monthEnd, endDate)).day ?? 1
                let averageCompletions = completions.count / max(1, daysInMonth)
                
                points.append(TrendPoint(
                    date: currentDate,
                    moodRating: averageMood,
                    habitCompletions: averageCompletions,
                    totalHabits: habitStore.habits.count
                ))
                
                currentDate = monthEnd
            }
            
            return points
            
        } else {
            // For week and month views, keep daily data
            var points: [TrendPoint] = []
            var currentDate = startDate
            
            while currentDate <= endDate {
                let dayStart = calendar.startOfDay(for: currentDate)
                let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
                
                // Get moods for the day
                let dayMoods = moodStore.moods.filter { mood in
                    (dayStart...dayEnd).contains(mood.timestamp)
                }
                let averageMood = dayMoods.isEmpty ? 0 :
                    Double(dayMoods.map(\.rating).reduce(0, +)) / Double(dayMoods.count)
                
                // Get habit completions for the day
                let completions = habitStore.completions.filter { completion in
                    (dayStart...dayEnd).contains(completion.date)
                }.count
                
                points.append(TrendPoint(
                    date: currentDate,
                    moodRating: averageMood,
                    habitCompletions: completions,
                    totalHabits: habitStore.habits.count
                ))
                
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }
            
            return points
        }
    }
    
    private var filteredActivities: [Activity] {
        let filterDate = getFilterDate()
        
        let moodActivities = moodStore.moods
            .filter { $0.timestamp >= filterDate }
            .map { Activity.mood($0) }
        
        let habitActivities = habitStore.habits.flatMap { habit in
            habitStore.completions
                .filter { $0.habitId == habit.id && $0.date >= filterDate }
                .map { Activity.habitCompletion(habit: habit, completion: $0) }
        }
        
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
    
    private func getAxisLabel(for date: Date) -> Text {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let isFirstDay = day == 1
        let isFirstDate = date == trendData.first?.date
        
        switch timeRange {
        case .week:
            return Text(date, format: .dateTime.weekday(.abbreviated))
        case .month:
            if isFirstDay || isFirstDate {
                return Text(date, format: .dateTime.month(.abbreviated))
            } else if day % 5 == 0 {
                return Text("\(day)")
            }
            return Text("")
        case .year:
            return Text(date, format: .dateTime.month(.abbreviated))
        }
    }
    
    private func getBarColor(habitCompletions: Int, totalHabits: Int) -> Color {
        if habitCompletions > 0 {
            return Color.blue.opacity(Double(habitCompletions) / Double(totalHabits))
        }
        return Color.gray.opacity(0.3)
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
                    
                    // Trend Chart
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Trends")
                            .font(.headline)
                            .foregroundColor(.primary.opacity(0.8))
                        
                        Chart(trendData) { point in
                            BarMark(
                                x: .value("Date", point.date),
                                y: .value("Mood", point.moodRating)
                            )
                            .foregroundStyle(getBarColor(habitCompletions: point.habitCompletions, totalHabits: point.totalHabits))
                        }
                        .chartXAxis {
                            AxisMarks(preset: .aligned) { value in
                                if let date = value.as(Date.self) {
                                    AxisValueLabel {
                                        getAxisLabel(for: date)
                                    }
                                }
                            }
                        }
                        .chartYAxis {
                            AxisMarks(values: [1, 2, 3, 4, 5]) { value in
                                AxisGridLine()
                                AxisTick()
                                AxisValueLabel {
                                    Text("\(value.as(Int.self) ?? 0)")
                                }
                            }
                        }
                        .chartYScale(domain: 0...5)
                        .frame(height: 200)

                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 10)
                    )
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
                                                    .fill(Color.blue.opacity(max((Double(rate) / 100), 0.2)))
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
