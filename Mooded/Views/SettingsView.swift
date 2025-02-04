import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationSettingsData") private var notificationSettingsData: Data = {
        if let encoded = try? JSONEncoder().encode(NotificationSettings.default) {
            return encoded
        }
        return Data()
    }()
    
    @State private var settings: NotificationSettings
    @State private var showingClearConfirmation = false
    @ObservedObject var moodStore: MoodStore
    
    init(moodStore: MoodStore) {
        self.moodStore = moodStore
        
        if let data = UserDefaults.standard.data(forKey: "notificationSettingsData"),
           let decoded = try? JSONDecoder().decode(NotificationSettings.self, from: data) {
            _settings = State(initialValue: decoded)
        } else {
            _settings = State(initialValue: .default)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Daily Weather Checks")) {
                    Toggle("Enable Reminders", isOn: $settings.isEnabled)
                    
                    if settings.isEnabled {
                        DatePicker("First Check",
                                 selection: $settings.startTime,
                                 displayedComponents: .hourAndMinute)
                        
                        DatePicker("Last Check",
                                 selection: $settings.endTime,
                                 displayedComponents: .hourAndMinute)
                        
                        Stepper("Number of checks: \(settings.notificationsPerDay)",
                               value: $settings.notificationsPerDay,
                               in: 1...6)
                    }
                }
                
                if settings.isEnabled {
                    Section(header: Text("Scheduled Check Times")) {
                        ForEach(settings.dailyNotificationTimes(), id: \.self) { time in
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(.blue)
                                    .font(.footnote)
                                Text(time, style: .time)
                            }
                        }
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        showingClearConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Clear All Data")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .onChange(of: settings) { _, newValue in
                if let encoded = try? JSONEncoder().encode(newValue) {
                    notificationSettingsData = encoded
                    NotificationManager.shared.scheduleNotifications(settings: newValue)
                }
            }
            .confirmationDialog(
                "Are you sure you want to clear all mood data?",
                isPresented: $showingClearConfirmation,
                titleVisibility: .visible
            ) {
                Button("Clear All Data", role: .destructive) {
                    moodStore.clearData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }
}
