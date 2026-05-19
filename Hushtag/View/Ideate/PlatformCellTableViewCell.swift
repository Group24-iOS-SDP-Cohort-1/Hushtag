import UIKit

class PlatformCellTableViewCell: UITableViewCell {
   

    @IBOutlet var view: UIView!

    @IBOutlet var youtubebtn: UIButton!

    @IBOutlet var instagrambtn: UIButton!

    @IBOutlet var twitterbtn: UIButton!

    private var allButtons: [UIButton] = []
    private var selectedButton: UIButton?
    var onPlatformSelected: ((String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        view.backgroundColor = UIColor.systemGray4
        view.layer.cornerRadius = 16
        allButtons = [youtubebtn, instagrambtn, twitterbtn]
        allButtons.forEach { $0.addTarget(self, action: #selector(platformTapped(_:)), for: .touchUpInside) }
        youtubebtn.setTitle("YouTube", for: .normal)
        instagrambtn.setTitle("Instagram", for: .normal)
        twitterbtn.setTitle("Twitter", for: .normal)
    }

    @objc func platformTapped(_ sender: UIButton) {
        guard sender != selectedButton else { return }
        for button in allButtons {
            button.backgroundColor = UIColor.systemGray4
            button.setTitleColor(.white, for: .normal)
        }
        sender.backgroundColor = UIColor.accent
        sender.setTitleColor(.white, for: .normal)
        selectedButton = sender
        let platform = sender.currentTitle ?? ""
        onPlatformSelected?(platform)
    }

    func configure(selectedPlatform: String?) {
        // reset all
        youtubebtn.backgroundColor = .gray
        instagrambtn.backgroundColor = .gray
        twitterbtn.backgroundColor = .gray

        // highlight selected
        switch selectedPlatform {
        case "YouTube":
            youtubebtn.backgroundColor = .systemPurple
        case "Instagram":
            instagrambtn.backgroundColor = .systemPurple
        case "Twitter":
            twitterbtn.backgroundColor = .systemPurple
        default:
            break
        }
    }
}
