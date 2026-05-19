import UIKit

class MainFieldCell: UITableViewCell {
    @IBOutlet var textField: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none

        textField.borderStyle = .none
        textField.backgroundColor = .clear
    }
}
