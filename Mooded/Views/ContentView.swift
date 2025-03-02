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
    
    var body: some View {
        TabView {
            NavigationView {
                HomeView(
                    moodStore: moodStore,
                    habitStore: habitStore,
                    selectedRating: $selectedRating
                )
            }
            .tabItem {
                Label("Today", systemImage: "cloud.sun.fill")
            }
            
            HistoryView(moodStore: moodStore, habitStore: habitStore)
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

// MARK: - Supporting Views
struct HomeView: View {
    @ObservedObject var moodStore: MoodStore
    @ObservedObject var habitStore: HabitStore
    @Binding var selectedRating: Int?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                TimeDisplayCard()
                
                MoodEntryCard(
                    selectedRating: $selectedRating,
                    moodStore: moodStore,
                    moodColor: moodColor,
                    weatherIcon: weatherIcon
                )
                
                if !habitStore.habits.isEmpty {
                    DailyHabitsCard(habitStore: habitStore)
                }

            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private func moodColor(for rating: Int) -> Color {
        switch rating {
        case 1: return .indigo.opacity(0.8)
        case 2: return .blue.opacity(0.5)
        case 3: return .gray.opacity(0.8)
        case 4: return .yellow.opacity(0.8)
        case 5: return .orange.opacity(0.8)
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
}

struct MoodEntryCard: View {
    @Binding var selectedRating: Int?
    @ObservedObject var moodStore: MoodStore
    let moodColor: (Int) -> Color
    let weatherIcon: (Int) -> String
    
    var body: some View {
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
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation {
                                selectedRating = nil
                            }
                        }
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: weatherIcon(rating))
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
                                      moodColor(rating) :
                                        Color.secondary.opacity(0.1))
                                .shadow(color: rating == selectedRating ?
                                       moodColor(rating).opacity(0.3) : .clear,
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
    }
}

struct DailyHabitsCard: View {
    @ObservedObject var habitStore: HabitStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Daily Habits")
                .font(.headline)
                .foregroundColor(.primary.opacity(0.8))
            
            VStack(spacing: 12) {
                ForEach(habitStore.habits) { habit in
                    HabitRow(habit: habit, habitStore: habitStore)
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
}

struct HabitRow: View {
    let habit: Habit
    @ObservedObject var habitStore: HabitStore
    @State private var isPressed = false
    @State private var animationAmount: CGFloat = 1.0
    
    // Helper function to check if habit is completed today
    private func isCompletedToday(habitId: UUID) -> Bool {
        return habitStore.isHabitCompleted(habitId: habitId, date: Date())
    }
    
    var body: some View {
        HStack {
            Text(habit.name)
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .soft)
                impact.prepare()
                
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.8)) {
                    habitStore.toggleCompletion(habitId: habit.id)
                    isPressed = true
                    animationAmount = 1.2
                }
                
                impact.impactOccurred()
                
                // Reset animation state
                withAnimation(.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0.8)) {
                    isPressed = false
                    animationAmount = 1.0
                }
            }) {
                ZStack {
                    let isCompleted = isCompletedToday(habitId: habit.id)
                    
                    Circle()
                        .fill(isCompleted ? Color.green : Color.gray.opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .scaleEffect(animationAmount)
                .overlay(
                    Circle()
                        .stroke(isCompletedToday(habitId: habit.id) ? Color.green : Color.clear, lineWidth: 2)
                        .scaleEffect(isPressed ? 1.2 : 1.0)
                        .opacity(isPressed ? 0.0 : 1.0)
                )
            }
            .buttonStyle(PlainButtonStyle())
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

struct TimeDisplayCard: View {
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var pulseScale: CGFloat = 1.0
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }()
    
    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm"
        return formatter
    }()
    
    private let secondsFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "ss"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geometry in
                VStack(spacing: 4) {
                    Text(dateFormatter.string(from: currentTime))
                        .font(.system(size: geometry.size.width * 0.13, weight: .medium, design: .rounded))
                        .foregroundColor(.primary.opacity(0.7))
                    
                    Text(monthFormatter.string(from: currentTime))
                        .font(.system(size: geometry.size.width * 0.11, weight: .medium, design: .rounded))
                        .foregroundColor(.primary.opacity(0.6))
                    
                    HStack(alignment: .bottom, spacing: 4) {
                        Text(timeFormatter.string(from: currentTime))
                            .font(.system(size: geometry.size.width * 0.25, weight: .light, design: .rounded))
                            .foregroundColor(.primary.opacity(0.8))
                            .scaleEffect(pulseScale)
                        
                        Text(secondsFormatter.string(from: currentTime))
                            .font(.system(size: geometry.size.width * 0.08, weight: .light, design: .rounded))
                            .foregroundColor(.primary.opacity(0.4))
                            .offset(y: -geometry.size.width * 0.05)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(height: UIScreen.main.bounds.height * 0.30)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 5)
        )
        .padding(.horizontal)
        .onReceive(timer) { input in
            currentTime = input
            withAnimation(.easeInOut(duration: 1.5)) {
                pulseScale = 1.01
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    withAnimation(.easeInOut(duration: 1.5)) {
                        pulseScale = 1.0
                    }
                }
            }
        }
    }
}
