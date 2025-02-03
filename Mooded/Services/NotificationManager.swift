import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Notification authorization granted")
            } else if let error = error {
                print("Notification authorization failed: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleNotifications(settings: NotificationSettings) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        guard settings.isEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Mood Check"
        content.body = "How are you feeling right now?"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: settings.frequency.timeInterval,
            repeats: true
        )
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}
