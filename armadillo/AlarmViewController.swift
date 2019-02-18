import UIKit

class AlarmViewController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var alarm: Alarm!
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var caption: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tapToSelectImage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = alarm.name
        name.text = alarm.name
        caption.text = alarm.caption
        datePicker.date = alarm.time
        
        if alarm.image.count > 0 {
            //if we have an image, try to load it
            let imageFileName = Helper.getDocumentsDirectory().appendingPathComponent(alarm.image)
            imageView.image = UIImage(contentsOfFile: imageFileName.path)
            tapToSelectImage.isHidden = true
        }
    }
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        alarm.time = datePicker.date
        save()
    }
    
    @IBAction func imageViewTapped(_ sender: UITapGestureRecognizer) {
        let vc = UIImagePickerController()
        vc.modalPresentationStyle = .pageSheet
        vc.delegate = self
        present(vc, animated: true)
    }
    
    //MARK: - Text field delegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        alarm.name = name.text!
        alarm.caption = caption.text!
        title = alarm.name
        save()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - Image picker view controller delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //dismiss the image picker
        dismiss(animated: true)
        
        //fetch picked image
        guard let image = info[.originalImage] as? UIImage else {return}
        let fm = FileManager()
        
        if alarm.image.count > 0 {
            //alarm already has an image
            do {
                let currentImage = Helper.getDocumentsDirectory().appendingPathComponent(alarm.image)
                
                if fm.fileExists(atPath: currentImage.path) {
                    try fm.removeItem(at: currentImage)
                }
            } catch {
                print("Failed to remove current image")
            }
        }
        
        do {
            //generate new filename
            alarm.image = "\(UUID().uuidString).jpg"
            
            let newPath = Helper.getDocumentsDirectory().appendingPathComponent(alarm.image)
            
            let jpeg = image.jpegData(compressionQuality: 0.8)
            try jpeg?.write(to: newPath)
            save()
        } catch {
            print("Failed to save new image")
        }
        
        //update UI
        imageView.image = image
        tapToSelectImage.isHidden = true
    }
    
    @objc func save() {
        let state = AlarmChangeState.modified(alarm)
        NotificationCenter.default.post(name: Notification.Name("save"), object: state)
    }
}
