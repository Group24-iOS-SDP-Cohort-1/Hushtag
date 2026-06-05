import UIKit

class PostFieldCell: UITableViewCell {
    let textField = UITextField()
    private let titleLabel = UILabel()
    private var sharedTextField: UITextField?
    private var customView: UIView?
    private var overlayMenuButton: UIButton?

    private let stackView = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .secondarySystemGroupedBackground

        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        titleLabel.isHidden = true

        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.font = .systemFont(ofSize: 16)

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(textField)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
            stackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 24)
        ])
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func resetAccessory() {
        textField.rightView = nil
        textField.rightViewMode = .never
        textField.inputView = nil
        textField.inputAccessoryView = nil
        textField.text = ""
        textField.isHidden = false
        textField.textAlignment = .left

        titleLabel.isHidden = true
        titleLabel.text = nil

        customView?.removeFromSuperview()
        customView = nil

        sharedTextField?.removeFromSuperview()
        sharedTextField = nil

        overlayMenuButton?.removeFromSuperview()
        overlayMenuButton = nil
    }

    func setTitle(_ text: String?) {
        if let text = text {
            titleLabel.text = text
            titleLabel.isHidden = false
        } else {
            titleLabel.isHidden = true
        }
    }

    func install(textField shared: UITextField, title: String?) {
        textField.isHidden = true
        sharedTextField = shared
        shared.borderStyle = .none
        shared.backgroundColor = .clear
        shared.font = .systemFont(ofSize: 16)

        stackView.addArrangedSubview(shared)
        setTitle(title)
    }

    func install(view: UIView) {
        textField.isHidden = true
        customView = view
        stackView.addArrangedSubview(view)
    }

    func addOverlay(_ button: UIButton) {
        overlayMenuButton = button
        button.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button)
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            button.topAnchor.constraint(equalTo: contentView.topAnchor),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

class PostMediaCell: UITableViewCell {
    let uploadButton = UIButton(type: .system)
    let removeButton = UIButton(type: .system)
    let previewLabel = UILabel()

    let thumbnailUploadButton = UIButton(type: .system)
    let thumbnailRemoveButton = UIButton(type: .system)
    let thumbnailPreviewLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear

        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 12
        container.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(container)

        uploadButton.setImage(UIImage(systemName: "video.badge.plus"), for: .normal)
        uploadButton.backgroundColor = .secondarySystemFill
        uploadButton.layer.cornerRadius = 12
        uploadButton.layer.masksToBounds = true
        uploadButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        uploadButton.heightAnchor.constraint(equalToConstant: 60).isActive = true

        let infoStack = UIStackView()
        infoStack.axis = .horizontal
        infoStack.spacing = 8
        infoStack.alignment = .center
        infoStack.translatesAutoresizingMaskIntoConstraints = false

        removeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        removeButton.tintColor = .systemRed
        removeButton.isHidden = true
        removeButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        removeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true

        previewLabel.font = .systemFont(ofSize: 14)
        previewLabel.textColor = .secondaryLabel
        previewLabel.isHidden = true

        infoStack.addArrangedSubview(previewLabel)
        infoStack.addArrangedSubview(removeButton)

        container.addArrangedSubview(uploadButton)
        container.addArrangedSubview(infoStack)

        setupThumbnailUI(in: container)

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    private func setupThumbnailUI(in container: UIStackView) {
        thumbnailUploadButton.setImage(UIImage(systemName: "photo.badge.plus"), for: .normal)
        thumbnailUploadButton.backgroundColor = .secondarySystemFill
        thumbnailUploadButton.layer.cornerRadius = 12
        thumbnailUploadButton.layer.masksToBounds = true
        thumbnailUploadButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        thumbnailUploadButton.heightAnchor.constraint(equalToConstant: 60).isActive = true

        let thumbInfoStack = UIStackView()
        thumbInfoStack.axis = .horizontal
        thumbInfoStack.spacing = 8
        thumbInfoStack.alignment = .center
        thumbInfoStack.translatesAutoresizingMaskIntoConstraints = false

        thumbnailRemoveButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        thumbnailRemoveButton.tintColor = .systemRed
        thumbnailRemoveButton.isHidden = true
        thumbnailRemoveButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        thumbnailRemoveButton.heightAnchor.constraint(equalToConstant: 30).isActive = true

        thumbnailPreviewLabel.font = .systemFont(ofSize: 14)
        thumbnailPreviewLabel.textColor = .secondaryLabel
        thumbnailPreviewLabel.isHidden = true

        thumbInfoStack.addArrangedSubview(thumbnailPreviewLabel)
        thumbInfoStack.addArrangedSubview(thumbnailRemoveButton)

        container.addArrangedSubview(thumbnailUploadButton)
        container.addArrangedSubview(thumbInfoStack)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
