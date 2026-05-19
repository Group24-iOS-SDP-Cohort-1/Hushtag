import UIKit

class DynamicItemCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var titleField: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!

    var titleChanged: ((String) -> Void)?
    var dateChanged: ((Date) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        titleField.delegate = self
        titleField.textContainerInset = .zero
        titleField.textContainer.lineFragmentPadding = 0
    }

    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        titleChanged?(textView.text ?? "")
    }

    @IBAction func dateDidChange(sender: UIDatePicker) {
        dateChanged?(sender.date)
    }

    func configure(title: String, placeholder: String, date: Date) {
        titleField.text = title
        placeholderLabel.text = placeholder
        placeholderLabel.isHidden = !title.isEmpty
        datePicker.date = date
    }
}
