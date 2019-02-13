import Foundation
class Group: NSObject {
    var id: String
    var name: String
    var playSound: Bool
    var enabled: Bool
    /// Array of nested alarms in group
    var alarms: [Alarm]
    
    init(name: String, playSound: Bool, enabled: Bool, alarms: [Alarm]) {
        self.id = UUID().uuidString
        self.name = name
        self.playSound = playSound
        self.enabled = enabled
        self.alarms = alarms
        super.init()
    }
}
