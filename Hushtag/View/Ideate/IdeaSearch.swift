import UIKit

protocol IdeaSearchDelegate: AnyObject {
    func didTapSearch(with keyword: String)
}

class IdeaSearch: UICollectionReusableView {
    @IBOutlet weak var textView: UIView!
    @IBOutlet weak var textLabel: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var textStack: UIStackView!

    @IBOutlet weak var mainHeadingStack: UIStackView!

    @IBOutlet weak var crossButton: UIButton!
    weak var delegate: IdeaSearchDelegate?

    enum SearchState {
        case ideateMain
        case afterSearch(showCross: Bool)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        textView.layer.borderColor = UIColor.accent.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 20

        textLabel.attributedPlaceholder = NSAttributedString(
            string: "Enter keyword, topic or niche...",
            attributes: [
                .foregroundColor: UIColor.accent
            ]
        )

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textLabel.frame.height))
        textLabel.leftView = paddingView
        textLabel.leftViewMode = .always

        // Initial defaults setup appropriately
        configure(state: .ideateMain)
        setupKeyboardDismissGesture()
    }

    func configure(state: SearchState) {
        // textStack contains all 3 headings, it MUST stay visible
        textStack.isHidden = false

        switch state {
        case .ideateMain:
            mainHeadingStack.isHidden = false
            crossButton.isHidden = true

        case .afterSearch(let showCross):
            //            mainHeadingStack.isHidden = true
            //            subheadingStack.isHidden = true
            textStack.isHidden = true
            crossButton.isHidden = !showCross
        }
    }

    private func setupKeyboardDismissGesture() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )

        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        textLabel.resignFirstResponder()
    }

    @IBAction func searchTap(_ sender: UIButton) {
        let keyword = textLabel.text ?? ""
        guard !keyword.isEmpty else {
            return
        }
        textLabel.resignFirstResponder()
        delegate?.didTapSearch(with: keyword)
    }

    @IBAction func crossTap(_ sender: UIButton) {
        textLabel.text = ""
        textLabel.resignFirstResponder()
        delegate?.didTapSearch(with: "")
    }
}
