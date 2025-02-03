import SwiftUI

struct ContentView: View {
    @StateObject private var moodStore = MoodStore()
    @State private var showingMoodEntry = false
    
    var body: some View {
        TabView {
            Button(action: {
                showingMoodEntry = true
            }) {
                Text("Record Mood")
                    .font(.title2)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .tabItem {
                Label("Record", systemImage: "plus.circle.fill")
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
