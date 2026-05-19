import UIKit

class ViewScriptsCell: UICollectionViewCell {
    @IBOutlet var content: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var readMoreButton: UIButton!
    @IBOutlet var tagDealButton: UIButton!

    private var fullText: String = ""
    private var isExpanded = false

    lazy var editableTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isScrollEnabled = false
        tv.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.5)
        tv.layer.cornerRadius = 8
        tv.isHidden = true
        tv.delegate = self
        return tv
    }()

    var textChangedHandler: ((String) -> Void)?

    func configure(with text: String) {
        fullText = text
        content.numberOfLines = 8
        content.attributedText = text.toStyledScript()
    }

    func configureTitle(with text: String) {
        fullText = text
        titleLabel.text = text
    }

    func setEditingMode(_ isEditing: Bool, isTitle: Bool) {
        let targetLabel = isTitle ? titleLabel : content
        guard let label = targetLabel else { return }

        if editableTextView.superview == nil {
            label.superview?.addSubview(editableTextView)
            NSLayoutConstraint.activate([
                editableTextView.leadingAnchor.constraint(equalTo: label.leadingAnchor),
                editableTextView.trailingAnchor.constraint(equalTo: label.trailingAnchor),
                editableTextView.topAnchor.constraint(equalTo: label.topAnchor),
                editableTextView.bottomAnchor.constraint(equalTo: label.bottomAnchor)
            ])
        }

        if isTitle {
            editableTextView.font = UIFont.boldSystemFont(ofSize: 25)
            editableTextView.textAlignment = .center
        } else {
            editableTextView.font = UIFont.preferredFont(forTextStyle: .body)
            editableTextView.textAlignment = .natural
        }

        if isEditing {
            editableTextView.text = fullText
            editableTextView.isHidden = false
            label.isHidden = true
            readMoreButton?.isHidden = true
        } else {
            editableTextView.isHidden = true
            label.isHidden = false
            readMoreButton?.isHidden = false
        }
    }

    private func collapsedText(_ text: String) -> NSAttributedString {
        let readMore = "... Read more"

        let attributed = NSMutableAttributedString(
            string: text,
            attributes: [.foregroundColor: UIColor.label]
        )

        let readMoreAttr = NSAttributedString(
            string: readMore,
            attributes: [.foregroundColor: UIColor.tintColor]
        )

        attributed.append(readMoreAttr)
        return attributed
    }

    @objc private func handleTap() {
        guard !isExpanded else { return }

        isExpanded = true
        content.numberOfLines = 0
        content.text = fullText

        var view = superview
        while view != nil {
            if let cv = view as? UICollectionView {
                cv.performBatchUpdates(nil)
                break
            }
            view = view?.superview
        }
    }
}

extension ViewScriptsCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        fullText = textView.text
        textChangedHandler?(textView.text)

        UIView.setAnimationsEnabled(false)
        var view = superview
        while view != nil {
            if let cv = view as? UICollectionView {
                cv.performBatchUpdates(nil)
                break
            }
            view = view?.superview
        }
        UIView.setAnimationsEnabled(true)
    }
}
