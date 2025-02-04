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
        content.title = "Weather Check"
        content.body = "How are you feeling?"
        content.sound = .default
        
        // Get notification times
        let times = settings.dailyNotificationTimes()
        
        // Schedule each notification
        for (index, time) in times.enumerated() {
            let components = Calendar.current.dateComponents([.hour, .minute], from: time)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            
            let request = UNNotificationRequest(
                identifier: "weatherCheck_\(index)",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request)
        }
    }
}
