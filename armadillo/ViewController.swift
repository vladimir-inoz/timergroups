import UIKit
import UserNotifications

/// This View Controller indicates list of all alarm groups
class ViewController: UITableViewController, UNUserNotificationCenterDelegate {
    var groups = [Group]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleAttributes = [NSAttributedString.Key.font : UIFont(name: "Arial Rounded MT Bold", size: 20)!]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        title = "Armadillo"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addGroup))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Groups", style: .plain, target: nil, action: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(save), name: Notification.Name("save"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        load()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        groups.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        save()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Group", for: indexPath)
        let group = groups[indexPath.row]
        cell.textLabel?.text = group.name
        
        if group.enabled {
            cell.textLabel?.textColor = UIColor.black
        } else {
            cell.textLabel?.textColor = UIColor.red
        }
        
        if group.alarms.count == 1 {
            cell.detailTextLabel?.text = "1 alarm"
        } else {
            cell.detailTextLabel?.text = "\(group.alarms.count) alarms"
        }
        
        return cell
    }
    
    @objc func addGroup() {
        let newGroup = Group(name: "Name this group", playSound: true, enabled: true, alarms: [])
        groups.append(newGroup)
        save()
        performSegue(withIdentifier: "EditGroup", sender: newGroup)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let groupToEdit: Group
        
        if sender is Group {
            groupToEdit = sender as! Group
        } else {
            guard let selectedIndexPath = tableView.indexPathForSelectedRow else {return}
            groupToEdit = groups[selectedIndexPath.row]
        }
        
        if let groupViewController = segue.destination as? GroupViewController {
            groupViewController.group = groupToEdit
        }
    }
    
    //MARK: - Notifications
    
    func createNotifications() {
        let center = UNUserNotificationCenter.current()
        
        center.removeAllPendingNotificationRequests()
        
        for group in groups {
            //ignore disabled groups
            guard group.enabled else { continue }
            
            for alarm in group.alarms {
                //create a notification request from each alarm
                let notification = createNotificationRequest(group: group, alarm: alarm)
                //schedule the notification for delivery
                center.add(notification) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error)")
                    }
                }
            }
        }
    }
    
    func createNotificationRequest(group: Group, alarm: Alarm) -> UNNotificationRequest {
        //creating the content for the notification
        let content = UNMutableNotificationContent()
        
        //assign the user's name and caption
        content.title = alarm.name
        content.body = alarm.caption
        
        //give it and identifier we can attach to custom buttons later on
        content.categoryIdentifier = "alarm"
        //attach the group ID and alarm ID for this alarm
        content.userInfo = ["group": group.id, "alarm": alarm.id]
        //if the user requested a sound for this group, attach their default alert sound
        if group.playSound {
            content.sound = UNNotificationSound.default
        }
        //use createNotificationAttachments to attach a picture for this alert if there's one
        content.attachments = createNotificationAttachments(alarm: alarm)
        //get a calendar ready to pull out date components
        let cal = Calendar.current
        //pull out the hour and minute components from this alarm's date
        let dateComponents = cal.dateComponents([.hour, .minute], from: alarm.time)
        //create a trigger matching those date components, set to repeat
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        //combine the content and the trigger to create a notification request
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        return request
    }
    
    /// Create image attachment as a copy of exsting image
    /// because notification attachment moves image to another location
    ///
    /// - Parameter alarm: source alarm
    /// - Returns: array of attachments
    func createNotificationAttachments(alarm: Alarm) -> [UNNotificationAttachment] {
        //return it there is no image to attach
        guard alarm.image.count > 0 else {return []}
        
        let fm = FileManager.default
        
        do {
            //full path to original image
            let imageURL = Helper.getDocumentsDirectory().appendingPathComponent(alarm.image)
            //create temp filename
            let copyURL = Helper.getDocumentsDirectory().appendingPathComponent("\(UUID().uuidString).jpg")
            //copy existing image to that new filename
            try fm.copyItem(at: imageURL, to: copyURL)
            //create an attaichment from the temporary filename, giving it a random number
            let attachment = try UNNotificationAttachment(identifier: UUID().uuidString, url: copyURL)
            
            return [attachment]
        } catch {
            print("Failed to attach alarm image: \(error)")
            return []
        }
    }
    
    func updateNotifications() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound]) {
            [unowned self] (granted, error) in
            if granted {
                self.createNotifications()
            }
        }
    }
    
    //MARK: - Archiving and unarchiving routines
    
    @objc func save() {
        do {
            let path = Helper.getDocumentsDirectory().appendingPathComponent("group.data")
            let data = try NSKeyedArchiver.archivedData(withRootObject: groups, requiringSecureCoding: false)
            try data.write(to: path)
        } catch {
            print("failed to save")
        }
        updateNotifications()
    }
    
    func load() {
        do {
            let path = Helper.getDocumentsDirectory().appendingPathComponent("group.data")
            let data = try Data(contentsOf: path)
            groups = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Group] ?? [Group]()
        } catch {
            print("Failed to load")
        }
        
        tableView.reloadData()
    }
    
    //MARK: - Notification center delegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }
    
    func display(group groupID: String) {
        _ = navigationController?.popToRootViewController(animated: false)
        
        for group in groups {
            if group.id == groupID {
                performSegue(withIdentifier: "EditGroup", sender: group)
                return
            }
        }
    }
    
    func destroy(group groupID: String) {
        _ = navigationController?.popToRootViewController(animated: false)
        
        for (index, group) in groups.enumerated() {
            if group.id == groupID {
                groups.remove(at: index)
                break
            }
        }
        
        save()
        load()
    }
    
    func rename(group groupID: String, newName: String) {
        _ = navigationController?.popToRootViewController(animated: false)
        
        for group in groups {
            if group.id == groupID {
                group.name = newName
                break
            }
        }
        
        save()
        load()
    }
    
    //This method is triggered when user interacts with our notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //pull out userInfo dictionary
        let userInfo = response.notification.request.content.userInfo
        
        if let groupID = userInfo["group"] as? String {
            //handling different actions
            switch response.actionIdentifier {
                //the user swiped to unlock, do nothing
            case UNNotificationDefaultActionIdentifier:
                print("Default identifier")
            //the user dismissed the alert, do nothing
            case UNNotificationDismissActionIdentifier:
                print("Dismiss identifier")
                //user asked to see the group
            case "show":
                display(group: groupID)
                //the user asked to destroy the group, so call `destroy()`
            case "destroy":
                destroy(group: groupID)
                //the user asked to rename the group, so safely unwrap their text response and call `rename()`
            case "rename":
                if let textResponse = response as? UNTextInputNotificationResponse {
                    rename(group: groupID, newName: textResponse.userText)
                }
            default:
                break
            }
            
            //call the completion handler when done
            completionHandler()
        }
    }
}

