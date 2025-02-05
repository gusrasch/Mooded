import SwiftUI

struct ContentView: View {
    @StateObject private var moodStore = MoodStore()
    @StateObject private var habitStore = HabitStore()
    @State private var selectedRating: Int?
    @Environment(\.colorScheme) var colorScheme
    
    private let weatherGradient = LinearGradient(
        colors: [Color.blue.opacity(0.6), Color.cyan.opacity(0.3)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var averageMood: Double {
        guard !moodStore.moods.isEmpty else { return 0 }
        return Double(moodStore.moods.map(\.rating).reduce(0, +)) / Double(moodStore.moods.count)
    }
    
    var currentStreak: Int {
        guard !moodStore.moods.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        var currentDate = calendar.startOfDay(for: Date())
        var streak = 0
        
        // Sort moods by date in descending order and group by day
        let dailyMoods = Dictionary(grouping: moodStore.moods) { mood in
            calendar.startOfDay(for: mood.timestamp)
        }
        
        while dailyMoods[currentDate] != nil {
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }
        
        return streak
    }
    
    var recentMoods: [Mood] {
        Array(moodStore.moods.suffix(7).reversed())
    }
    
    private func moodColor(for rating: Int) -> Color {
        switch rating {
        case 1: return .indigo.opacity(0.8)      // Stormy
        case 2: return .blue.opacity(0.5)        // Rainy
        case 3: return .gray.opacity(0.8)        // Cloudy
        case 4: return .yellow.opacity(0.8)      // Partly sunny
        case 5: return .orange.opacity(0.8)      // Sunny
        default: return .gray
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
        TabView {
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        // Mood Entry Card
                        VStack(spacing: 16) {
                            Text("How are you feeling?")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.primary.opacity(0.8))
                            
                            HStack(spacing: 12) {
                                ForEach(1...5, id: \.self) { rating in
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                            moodStore.add(Mood(rating: rating))
                                            selectedRating = rating
                                        }
                                        // Reset selection with animation
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            withAnimation {
                                                selectedRating = nil
                                            }
                                        }
                                    }) {
                                        VStack(spacing: 8) {
                                            Image(systemName: weatherIcon(for: rating))
                                                .font(.system(size: 28))
                                                .symbolEffect(.bounce, value: selectedRating == rating)
                                            Text("\(rating)")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                        }
                                        .frame(width: 64, height: 64)
                                        .background(
                                            Circle()
                                                .fill(rating == selectedRating ?
                                                      moodColor(for: rating) :
                                                        Color.secondary.opacity(0.1))
                                                .shadow(color: rating == selectedRating ?
                                                       moodColor(for: rating).opacity(0.3) : .clear,
                                                       radius: 8, x: 0, y: 4)
                                        )
                                        .foregroundColor(rating == selectedRating ? .white : .primary)
                                    }
                                    .scaleEffect(selectedRating == rating ? 1.1 : 1.0)
                                }
                            }
                        }
                        .padding(.vertical, 24)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                        )
                        
                        // Daily Habits Card
                        if !habitStore.habits.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Daily Habits")
                                    .font(.headline)
                                    .foregroundColor(.primary.opacity(0.8))
                                
                                VStack(spacing: 12) {
                                    ForEach(habitStore.habits) { habit in
                                        HStack {
                                            Text(habit.name)
                                                .foregroundColor(.primary)
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                withAnimation {
                                                    habitStore.toggleCompletion(habitId: habit.id)
                                                }
                                            }) {
                                                Image(systemName: habitStore.isHabitCompleted(habitId: habit.id) ? "checkmark.circle.fill" : "circle")
                                                    .foregroundColor(habitStore.isHabitCompleted(habitId: habit.id) ? .green : .gray)
                                                    .font(.system(size: 24))
                                            }
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(.systemBackground))
                                                .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
                                        )
                                    }
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                            )
                        }
                        
                        if !moodStore.moods.isEmpty {
                            // Mood Summary Card
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Weather Report")
                                    .font(.headline)
                                    .foregroundColor(.primary.opacity(0.8))
                                
                                HStack(spacing: 30) {
                                    VStack(spacing: 8) {
                                        Text("\(averageMood, specifier: "%.1f")")
                                            .font(.system(size: 32, weight: .bold, design: .rounded))
                                        Text("Average")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    VStack(spacing: 8) {
                                        Text("\(moodStore.moods.count)")
                                            .font(.system(size: 32, weight: .bold, design: .rounded))
                                        Text("Entries")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    VStack(spacing: 8) {
                                        Text("\(currentStreak)")
                                            .font(.system(size: 32, weight: .bold, design: .rounded))
                                        Text("Day Streak")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                            )
                            
                            // Recent Moods
                            if !recentMoods.isEmpty {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Recent Weather")
                                        .font(.headline)
                                        .foregroundColor(.primary.opacity(0.8))
                                    
                                    ForEach(recentMoods) { mood in
                                        HStack {
                                            Image(systemName: weatherIcon(for: mood.rating))
                                                .foregroundColor(moodColor(for: mood.rating))
                                                .font(.system(size: 20))
                                            
                                            Text(mood.timestamp, style: .relative)
                                                .foregroundColor(.secondary)
                                                .font(.subheadline)
                                            
                                            Spacer()
                                            
                                            Text("\(mood.rating)")
                                                .fontWeight(.semibold)
                                                .foregroundColor(.primary.opacity(0.8))
                                        }
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(.systemBackground))
                                                .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
                                        )
                                    }
                                }
                                .padding(20)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                                )
                            }
                        }
                    }
                    .padding()
                }
                .background(Color(.systemGroupedBackground))
            }
            .tabItem {
                Label("Today", systemImage: "cloud.sun.fill")
            }
            
            MoodHistoryView(moodStore: moodStore)
                .tabItem {
                    Label("History", systemImage: "calendar")
                }
            
            SettingsView(moodStore: moodStore, habitStore: habitStore)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .onAppear {
            NotificationManager.shared.requestAuthorization()
        }
    }
}
