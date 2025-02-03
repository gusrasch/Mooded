import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationSettingsData") private var notificationSettingsData: Data = try! JSONEncoder().encode(NotificationSettings(isEnabled: true, frequency: .twentyFourHours))
    @State private var settings: NotificationSettings
    
    init() {
        let initialSettings = try! JSONDecoder().decode(NotificationSettings.self, from: UserDefaults.standard.data(forKey: "notificationSettingsData") ?? Data())
        _settings = State(initialValue: initialSettings)
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
                notificationSettingsData = try! JSONEncoder().encode(newValue)
                NotificationManager.shared.scheduleNotifications(settings: newValue)
            }
        }
    }
}
