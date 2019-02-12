import UIKit

class AlarmViewController: UITableViewController, UITextViewDelegate {
    var alarm: Alarm!
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var caption: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tapToSelectImage: UILabel!
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
    }
    
    @IBAction func imageViewTapped(_ sender: UITapGestureRecognizer) {
    }
}
