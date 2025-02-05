import SwiftUI

struct AddHabitView: View {
    @ObservedObject var habitStore: HabitStore
    let habit: Habit?
    @Binding var isPresented: Bool
    
    @State private var name: String = ""
    @State private var notificationEnabled: Bool = false
    @State private var notificationTime: Date = Date()
    @State private var showingError = false
    
    init(habitStore: HabitStore, habit: Habit? = nil, isPresented: Binding<Bool>) {
        self.habitStore = habitStore
        self.habit = habit
        self._isPresented = isPresented
        
        if let habit = habit {
            _name = State(initialValue: habit.name)
            _notificationEnabled = State(initialValue: habit.notificationTime != nil)
            if let time = habit.notificationTime {
                _notificationTime = State(initialValue: time)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Habit Name", text: $name)
                } header: {
                    Text("Habit Details")
                } footer: {
                    Text("Enter a short, descriptive name for your daily habit")
                }
                
                Section {
                    Toggle("Enable Reminder", isOn: $notificationEnabled)
                    
                    if notificationEnabled {
                        DatePicker("Reminder Time", selection: $notificationTime, displayedComponents: .hourAndMinute)
                    }
                } header: {
                    Text("Reminder Settings")
                } footer: {
                    Text("You'll receive a notification at the specified time each day")
                }
            }
            .navigationTitle(habit == nil ? "Add Habit" : "Edit Habit")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    saveHabit()
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            )
            .alert("Invalid Habit Name", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please enter a valid habit name")
            }
        }
    }
    
    private func saveHabit() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            showingError = true
            return
        }
        
        if let existingHabit = habit {
            let updatedHabit = Habit(
                id: existingHabit.id,
                name: trimmedName,
                isEnabled: true,
                notificationTime: notificationEnabled ? notificationTime : nil
            )
            habitStore.updateHabit(updatedHabit)
        } else {
            let newHabit = Habit(
                name: trimmedName,
                isEnabled: true,
                notificationTime: notificationEnabled ? notificationTime : nil
            )
            habitStore.addHabit(newHabit)
        }
        
        isPresented = false
    }
}
