import UIKit

/// This View Controller indicates list of all alarm groups
class ViewController: UITableViewController {
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
    
    //MARK: - Archiving and unarchiving routines
    
    @objc func save() {
        do {
            let path = Helper.getDocumentsDirectory().appendingPathComponent("group.data")
            let data = try NSKeyedArchiver.archivedData(withRootObject: groups, requiringSecureCoding: false)
            try data.write(to: path)
        } catch {
            print("failed to save")
        }
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
}

