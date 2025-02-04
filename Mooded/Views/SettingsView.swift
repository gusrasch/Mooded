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
    @State private var showingAddTime = false
    @State private var newTime = Date()
    @State private var isEditing = false
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
                Section {
                    Toggle("Enable Daily Reminders", isOn: $settings.isEnabled)
                } header: {
                    Text("Notifications")
                } footer: {
                    if settings.isEnabled && settings.scheduledTimes.isEmpty {
                        Text("Add check-in times below")
                    }
                }
                
                if settings.isEnabled {
                    Section {
                        ForEach(settings.scheduledTimes.sorted(by: { $0.time < $1.time })) { time in
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(.blue)
                                    .font(.footnote)
                                Text(time.time, style: .time)
                                    .foregroundStyle(.primary)
                                
                                if isEditing {
                                    Spacer()
                                    Button(role: .destructive) {
                                        if let index = settings.scheduledTimes.firstIndex(where: { $0.id == time.id }) {
                                            settings.scheduledTimes.remove(at: index)
                                            saveAndUpdateNotifications()
                                        }
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                        
                        Button(action: {
                            showingAddTime = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Check-in Time")
                            }
                        }
                    } header: {
                        HStack {
                            Text("Daily Check-ins")
                            Spacer()
                            if !settings.scheduledTimes.isEmpty {
                                Button(action: {
                                    withAnimation {
                                        isEditing.toggle()
                                    }
                                }) {
                                    Text(isEditing ? "Done" : "Edit")
                                }
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
            .sheet(isPresented: $showingAddTime) {
                NavigationView {
                    Form {
                        DatePicker("Time", selection: $newTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .padding()
                    }
                    .navigationTitle("Add Check-in Time")
                    .navigationBarItems(
                        leading: Button("Cancel") {
                            showingAddTime = false
                        },
                        trailing: Button("Add") {
                            settings.scheduledTimes.append(NotificationTime(time: newTime))
                            saveAndUpdateNotifications()
                            showingAddTime = false
                        }
                    )
                }
                .presentationDetents([.height(300)])
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
    
    private func saveAndUpdateNotifications() {
        if let encoded = try? JSONEncoder().encode(settings) {
            notificationSettingsData = encoded
            NotificationManager.shared.scheduleNotifications(settings: settings)
        }
    }
}
