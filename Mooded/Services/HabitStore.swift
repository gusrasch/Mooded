import SwiftUI
import Foundation

class HabitStore: ObservableObject {
    @Published private(set) var habits: [Habit] = []
    @Published private(set) var completions: [HabitCompletion] = []
    
    private let habitsKey = "SavedHabits"
    private let completionsKey = "HabitCompletions"
    
    init() {
        loadHabits()
        loadCompletions()
    }
    
    func addHabit(_ habit: Habit) {
        habits.append(habit)
        saveHabits()
        scheduleNotification(for: habit)
    }
    
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
            saveHabits()
            scheduleNotification(for: habit)
        }
    }
    
    func removeHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        completions.removeAll { $0.habitId == habit.id }
        saveHabits()
        saveCompletions()
        removeNotification(for: habit)
    }
    
    func toggleCompletion(habitId: UUID, date: Date = Date()) {
        let calendar = Calendar.current

        if let existing = completions.first(where: { completion in
            calendar.isDate(completion.date, inSameDayAs: date) && completion.habitId == habitId
        }) {
            completions.removeAll { $0.id == existing.id }
        } else {
            let completion = HabitCompletion(habitId: habitId, date: date)
            completions.append(completion)
        }
        saveCompletions()
    }
    
    func isHabitCompleted(habitId: UUID, date: Date = Date()) -> Bool {
        let calendar = Calendar.current
        return completions.contains { completion in
            calendar.isDate(completion.date, inSameDayAs: date) && completion.habitId == habitId
        }
    }
    
    private func saveHabits() {
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: habitsKey)
        }
    }
    
    private func loadHabits() {
        if let data = UserDefaults.standard.data(forKey: habitsKey),
           let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decoded
        }
    }
    
    private func saveCompletions() {
        if let encoded = try? JSONEncoder().encode(completions) {
            UserDefaults.standard.set(encoded, forKey: completionsKey)
        }
    }
    
    private func loadCompletions() {
        if let data = UserDefaults.standard.data(forKey: completionsKey),
           let decoded = try? JSONDecoder().decode([HabitCompletion].self, from: data) {
            completions = decoded
        }
    }
    
    private func scheduleNotification(for habit: Habit) {
        guard let notificationTime = habit.notificationTime, habit.isEnabled else {
            removeNotification(for: habit)
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Habit Reminder"
        content.body = habit.name
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "habit_\(habit.id)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func removeNotification(for habit: Habit) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["habit_\(habit.id)"])
    }
    
    func clearAll() {
        habits.removeAll()
        completions.removeAll()
        saveHabits()
        saveCompletions()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
