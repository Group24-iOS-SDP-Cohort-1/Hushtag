import UIKit

class PreferencesHeaderView: UICollectionReusableView {
    @IBOutlet var headerLabel: UILabel!

    func configureHeader(text: String) {
        headerLabel.text = text
        headerLabel.isHidden = text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
