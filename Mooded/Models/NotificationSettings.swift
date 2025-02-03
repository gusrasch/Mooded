import Foundation

struct NotificationSettings: Codable, Equatable {
    enum Frequency: String, Codable, CaseIterable {
        case sixHours = "6 hours"
        case twelveHours = "12 hours"
        case twentyFourHours = "24 hours"
        
        var timeInterval: TimeInterval {
            switch self {
            case .sixHours: return 6 * 60 * 60
            case .twelveHours: return 12 * 60 * 60
            case .twentyFourHours: return 24 * 60 * 60
            }
        }
    }
    
    var isEnabled: Bool
    var frequency: Frequency
    
    init(isEnabled: Bool = true, frequency: Frequency = .twentyFourHours) {
        self.isEnabled = isEnabled
        self.frequency = frequency
    }
}
