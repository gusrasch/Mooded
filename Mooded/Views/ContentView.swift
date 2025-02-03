import SwiftUI

struct ContentView: View {
    @StateObject private var moodStore = MoodStore()
    @State private var selectedRating: Int?
    
    var averageMood: Double {
        guard !moodStore.moods.isEmpty else { return 0 }
        return Double(moodStore.moods.map(\.rating).reduce(0, +)) / Double(moodStore.moods.count)
    }
    
    var recentMoods: [Mood] {
        Array(moodStore.moods.suffix(7).reversed())
    }
    
    var body: some View {
        TabView {
            NavigationView {
                ScrollView {
                    VStack(spacing: 24) {
                        // Quick Mood Entry
                        VStack(spacing: 16) {
                            Text("How are you feeling?")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            HStack(spacing: 16) {
                                ForEach(1...5, id: \.self) { rating in
                                    Button(action: {
                                        moodStore.add(Mood(rating: rating))
                                        selectedRating = rating
                                        // Animate rating selection away after 1 second
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                            selectedRating = nil
                                        }
                                    }) {
                                        VStack {
                                            Image(systemName: rating <= 2 ? "cloud.rain" :
                                                  rating == 3 ? "cloud" : "sun.max")
                                                .font(.system(size: 24))
                                            Text("\(rating)")
                                                .fontWeight(.medium)
                                        }
                                        .frame(width: 60, height: 60)
                                        .background(
                                            Circle()
                                                .fill(rating == selectedRating ?
                                                      Color.blue : Color.gray.opacity(0.1))
                                        )
                                        .foregroundColor(rating == selectedRating ?
                                                       .white : .primary)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(radius: 2)
                        
                        // Mood Stats
                        if !moodStore.moods.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Your Mood Summary")
                                    .font(.headline)
                                
                                HStack(spacing: 24) {
                                    VStack {
                                        Text("\(averageMood, specifier: "%.1f")")
                                            .font(.title)
                                            .fontWeight(.bold)
                                        Text("Average")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    VStack {
                                        Text("\(moodStore.moods.count)")
                                            .font(.title)
                                            .fontWeight(.bold)
                                        Text("Entries")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(16)
                            .shadow(radius: 2)
                            
                            // Recent Moods
                            if !recentMoods.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Recent Moods")
                                        .font(.headline)
                                    
                                    ForEach(recentMoods) { mood in
                                        HStack {
                                            Image(systemName: mood.rating <= 2 ? "cloud.rain" :
                                                  mood.rating == 3 ? "cloud" : "sun.max")
                                                .foregroundColor(mood.rating <= 2 ? .blue :
                                                                mood.rating == 3 ? .gray : .yellow)
                                            
                                            Text(mood.timestamp, style: .relative)
                                                .foregroundColor(.secondary)
                                            
                                            Spacer()
                                            
                                            Text("\(mood.rating)")
                                                .fontWeight(.semibold)
                                        }
                                        .padding(.vertical, 8)
                                    }
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(16)
                                .shadow(radius: 2)
                            }
                        }
                    }
                    .padding()
                }
                .background(Color(.systemGroupedBackground))
                .navigationTitle("Mood Tracker")
            }
            .tabItem {
                Label("Today", systemImage: "heart.fill")
            }
            
            MoodHistoryView(moodStore: moodStore)
                .tabItem {
                    Label("History", systemImage: "chart.bar.fill")
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
