import Foundation

struct NotificationSettings: Codable, Equatable {
    var isEnabled: Bool
    var startTime: Date  // Only hour/minute will be used
    var endTime: Date    // Only hour/minute will be used
    var notificationsPerDay: Int
    
    static let `default` = NotificationSettings(
        isEnabled: true,
        startTime: Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date(),
        endTime: Calendar.current.date(from: DateComponents(hour: 21, minute: 0)) ?? Date(),
        notificationsPerDay: 3
    )
    
    func dailyNotificationTimes() -> [Date] {
        guard isEnabled && notificationsPerDay > 0 else { return [] }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Extract hour and minute from start and end times
        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)
        
        guard let firstCheck = calendar.date(bySettingHour: startComponents.hour ?? 9,
                                           minute: startComponents.minute ?? 0,
                                           second: 0,
                                           of: today),
              let lastPossibleCheck = calendar.date(bySettingHour: endComponents.hour ?? 21,
                                                  minute: endComponents.minute ?? 0,
                                                  second: 0,
                                                  of: today) else {
            return []
        }
        
        // If only one notification, just return the start time
        if notificationsPerDay == 1 {
            return [firstCheck]
        }
        
        // Calculate interval between checks
        let totalMinutes = calendar.dateComponents([.minute], from: firstCheck, to: lastPossibleCheck).minute ?? 0
        let intervalMinutes = totalMinutes / (notificationsPerDay - 1) // -1 because first check is at start time
        
        var times = [firstCheck]
        
        // Add remaining checks
        for i in 1..<notificationsPerDay {
            if let checkTime = calendar.date(byAdding: .minute,
                                          value: intervalMinutes * i,
                                          to: firstCheck) {
                times.append(checkTime)
            }
        }
        
        return times
    }
}
