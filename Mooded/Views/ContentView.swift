import SwiftUI

struct ContentView: View {
    @StateObject private var moodStore = MoodStore()
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
    
    var recentMoods: [Mood] {
        Array(moodStore.moods.suffix(7).reversed())
    }
    
    private func moodColor(for rating: Int) -> Color {
        switch rating {
        case 1: return .blue.opacity(0.8)  // Rainy
        case 2: return .gray.opacity(0.8)  // Cloudy with rain
        case 3: return .gray               // Cloudy
        case 4: return .orange             // Partly sunny
        case 5: return .yellow             // Sunny
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
                        
                        if !moodStore.moods.isEmpty {
                            // Mood Summary Card
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Weather Report")
                                    .font(.headline)
                                    .foregroundColor(.primary.opacity(0.8))
                                
                                HStack(spacing: 40) {
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
                .navigationTitle("Weather of Mind")
            }
            .tabItem {
                Label("Today", systemImage: "cloud.sun.fill")
            }
            
            MoodHistoryView(moodStore: moodStore)
                .tabItem {
                    Label("History", systemImage: "calendar")
                }
            
            SettingsView(moodStore: moodStore)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .onAppear {
            NotificationManager.shared.requestAuthorization()
        }
    }
}
