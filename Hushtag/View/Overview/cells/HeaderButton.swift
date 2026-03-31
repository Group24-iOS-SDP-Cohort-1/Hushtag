import UIKit

class HeaderButton: UICollectionReusableView {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var backward: UIButton!
    @IBOutlet weak var forward: UIButton!
    
    var onDateChanged: ((Date) -> Void)?
    private var currentDate: Date = Date()
    override func awakeFromNib() {
        super.awakeFromNib()
        backward.addTarget(self, action: #selector(prevMonth), for: .touchUpInside)
        forward.addTarget(self, action: #selector(nextMonth), for: .touchUpInside)
    }
    func configure(text: String, date: Date) {
        headerLabel.text = text
        currentDate = date
    }
    
    @objc private func nextMonth() {
        changeMonth(by: 1)
    }

    @objc private func prevMonth() {
        changeMonth(by: -1)
    }

    private func changeMonth(by value: Int) {
        let calendar = Calendar.current
        guard let newDate = calendar.date(byAdding: .month, value: value, to: currentDate) else {
            return
        }
        onDateChanged?(newDate)
    }
}
