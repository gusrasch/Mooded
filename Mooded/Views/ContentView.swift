import SwiftUI

struct ContentView: View {
    @StateObject private var moodStore = MoodStore()
    @State private var showingMoodEntry = false
    
    var body: some View {
        TabView {
            MoodHistoryView(moodStore: moodStore)
                .tabItem {
                    Label("History", systemImage: "chart.line.uptrend.xyaxis")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .sheet(isPresented: $showingMoodEntry) {
            MoodEntryView(moodStore: moodStore)
        }
        .onAppear {
            NotificationManager.shared.requestAuthorization()
        }
    }
}
