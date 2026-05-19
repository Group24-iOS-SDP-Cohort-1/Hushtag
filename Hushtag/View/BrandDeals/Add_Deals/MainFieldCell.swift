import UIKit

class MainFieldCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none

        textField.borderStyle = .none
        textField.backgroundColor = .clear
    }
}
