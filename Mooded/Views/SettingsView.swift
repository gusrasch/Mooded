import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationSettingsData") private var notificationSettingsData: Data = {
        // Create default settings
        let defaultSettings = NotificationSettings(isEnabled: true, frequency: .twentyFourHours)
        // Encode them to Data, or return empty Data if encoding fails
        return (try? JSONEncoder().encode(defaultSettings)) ?? Data()
    }()
    
    @State private var settings: NotificationSettings
    @State private var showingClearConfirmation = false
    @ObservedObject var moodStore: MoodStore
    
    init(moodStore: MoodStore) {
        self.moodStore = moodStore
        // Safely decode settings or use defaults
        let defaultSettings = NotificationSettings(isEnabled: true, frequency: .twentyFourHours)
        
        if let data = UserDefaults.standard.data(forKey: "notificationSettingsData"),
           let decoded = try? JSONDecoder().decode(NotificationSettings.self, from: data) {
            _settings = State(initialValue: decoded)
        } else {
            _settings = State(initialValue: defaultSettings)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Notifications")) {
                    Toggle("Enable Reminders", isOn: $settings.isEnabled)
                    
                    if settings.isEnabled {
                        Picker("Frequency", selection: $settings.frequency) {
                            ForEach(NotificationSettings.Frequency.allCases, id: \.self) { frequency in
                                Text(frequency.rawValue).tag(frequency)
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
