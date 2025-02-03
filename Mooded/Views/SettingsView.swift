import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationSettingsData") private var notificationSettingsData: Data = {
        // Create default settings
        let defaultSettings = NotificationSettings(isEnabled: true, frequency: .twentyFourHours)
        // Encode them to Data, or return empty Data if encoding fails
        return (try? JSONEncoder().encode(defaultSettings)) ?? Data()
    }()
    
    @State private var settings: NotificationSettings
    
    init() {
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
            }
            .navigationTitle("Settings")
            .onChange(of: settings) { newValue in
                if let encoded = try? JSONEncoder().encode(newValue) {
                    notificationSettingsData = encoded
                    NotificationManager.shared.scheduleNotifications(settings: newValue)
                }
            }
        }
    }
}
