import Foundation

struct NotificationTime: Codable, Equatable, Identifiable {
    var id: UUID
    var time: Date  // Only hour/minute will be used
    
    init(time: Date) {
        self.id = UUID()
        self.time = time
    }
}

struct NotificationSettings: Codable, Equatable {
    var isEnabled: Bool
    var scheduledTimes: [NotificationTime]
    
    static let `default` = NotificationSettings(
        isEnabled: true,
        scheduledTimes: [
            NotificationTime(time: Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()),
            NotificationTime(time: Calendar.current.date(from: DateComponents(hour: 15, minute: 0)) ?? Date()),
            NotificationTime(time: Calendar.current.date(from: DateComponents(hour: 21, minute: 0)) ?? Date())
        ]
    )
    
    func dailyNotificationTimes() -> [Date] {
        guard isEnabled else { return [] }
        return scheduledTimes.map(\.time).sorted()
    }
}
