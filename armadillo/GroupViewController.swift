import UIKit

class GroupViewController: UITableViewController, UITextFieldDelegate {
    var group: Group!
    private let playSoundTag = 1001
    private let enabledTag = 1002
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAlarm))
        title = group.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        if sender.tag == playSoundTag {
            group.playSound = sender.isOn
        } else if sender.tag == enabledTag {
            group.enabled = sender.isOn
        }
        save()
    }
    
    //MARK: - Table view datasource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //return nothing if we're in the first section
        if section == 0 { return nil }
        //otherwise if we're still here, it means we're in the second section - do we have at least 1 alarm?
        if group.alarms.count > 0 { return "Alarms" }
        //if we're still here and have 0 alarms, so return nothing
        return nil
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else {
            return group.alarms.count
        }
    }
    
    func createGroupCell(for indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            //this is the first cell: editing the name of the group
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditableText", for: indexPath)
            //look for the text field inside the cell
            if let cellTextField = cell.viewWithTag(1) as? UITextField {
                //then give it the group name
                cellTextField.text = group.name
            }
            return cell
        case 1:
            //this is the "play sound" cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "Switch", for: indexPath)
            
            if let cellLabel = cell.viewWithTag(1) as? UILabel, let cellSwitch = cell.viewWithTag(2) as? UISwitch {
                //configure cell with correct settings
                cellLabel.text = "Play sound"
                cellSwitch.isOn = group.playSound
                //set the switch up with the playSoundTag so we know which one was changed later on
                cellSwitch.tag = playSoundTag
            }
            return cell
        default:
            //this is "enabled" switch
            let cell = tableView.dequeueReusableCell(withIdentifier: "Switch", for: indexPath)
            
            if let cellLabel = cell.viewWithTag(1) as? UILabel, let cellSwitch = cell.viewWithTag(2) as? UISwitch {
                //configure cell with correct settings
                cellLabel.text = "Enabled"
                cellSwitch.isOn = group.enabled
                //set the switch up with the playSoundTag so we know which one was changed later on
                cellSwitch.tag = enabledTag
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            //First section contains group parameters
            //Pass hard work onto a different method if we're in the first section
            return createGroupCell(for: indexPath, in: tableView)
        } else {
            //We're in alarm list
            //so pull out a RightDetail cell for display
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetail", for: indexPath)
            //pull out the correct alarm from the alarms array
            let alarm = group.alarms[indexPath.row]
            //use the alarm to configure the cell
            cell.textLabel?.text = alarm.name
            cell.detailTextLabel?.text = DateFormatter.localizedString(from: alarm.time, dateStyle: .none, timeStyle: .short)
            
            return cell
        }
    }
    
    //MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        group.alarms.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        save()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.preservesSuperviewLayoutMargins = true
        cell.contentView.preservesSuperviewLayoutMargins = true
    }
    
    //MARK: - text field delegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        group.name = textField.text!
        title = group.name
        save()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func addAlarm() {
        let newAlarm = Alarm(name: "Name this alarm", caption: "Add an optional description", time: Date(), image: "")
        group.alarms.append(newAlarm)
        performSegue(withIdentifier: "EditAlarm", sender: newAlarm)
        save()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let alarmToEdit: Alarm
        
        if sender is Alarm {
            alarmToEdit = sender as! Alarm
        } else {
            guard let selectedIndexPath = tableView.indexPathForSelectedRow else {return}
            alarmToEdit = group.alarms[selectedIndexPath.row]
        }
        
        if let alarmViewController = segue.destination as? AlarmViewController {
            alarmViewController.alarm = alarmToEdit
        }
    }
    
    @objc func save() {
        NotificationCenter.default.post(name: Notification.Name("save"), object: nil)
    }
}
