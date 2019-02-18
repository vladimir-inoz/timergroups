import Foundation

enum AlarmChangeState {
    case removed(String)
    case modified(Alarm)
    case added(Alarm)
}

class Alarm: NSObject, NSCoding {
    /// Unique ID of alarm
    var id: String
    /// Name of alarm
    var name: String
    /// Additional description
    var caption: String
    var time: Date
    var image: String
    
    init(name: String, caption: String, time: Date, image: String) {
        self.id = UUID().uuidString
        self.name = name
        self.caption = caption
        self.time = time
        self.image = image
        super.init()
    }
    
    //MARK: - NSCoding conformance
    
    required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObject(forKey: "id") as! String
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.caption = aDecoder.decodeObject(forKey: "caption") as! String
        self.time = aDecoder.decodeObject(forKey: "time") as! Date
        self.image = aDecoder.decodeObject(forKey: "image") as! String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.caption, forKey: "caption")
        aCoder.encode(self.time, forKey: "time")
        aCoder.encode(self.image, forKey: "image")
    }
}
