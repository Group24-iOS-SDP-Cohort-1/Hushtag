import UIKit

class CapsuleNotification: UIView {
    private let label = UILabel()
    private let iconImageView = UIImageView()
    private let stackView = UIStackView()

    private init() {
        super.init(frame: .zero)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        // Glass effect background with a subtle purple tint
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 25
        blurView.clipsToBounds = true
        addSubview(blurView)

        // Add a subtle purple tint overlay
        let tintView = UIView()
        tintView.backgroundColor = UIColor(red: 0.545, green: 0.361, blue: 0.965, alpha: 0.1) // Brand purple
        tintView.translatesAutoresizingMaskIntoConstraints = false
        blurView.contentView.addSubview(tintView)

        // Glowing border for premium feel
        blurView.layer.borderWidth = 1.0
        blurView.layer.borderColor = UIColor(red: 0.545, green: 0.361, blue: 0.965, alpha: 0.4).cgColor

        // StackView for Icon and Label
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        iconImageView.preferredSymbolConfiguration = .init(pointSize: 20, weight: .bold)

        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 1

        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(label)

        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),

            tintView.topAnchor.constraint(equalTo: blurView.topAnchor),
            tintView.leadingAnchor.constraint(equalTo: blurView.leadingAnchor),
            tintView.trailingAnchor.constraint(equalTo: blurView.trailingAnchor),
            tintView.bottomAnchor.constraint(equalTo: blurView.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 22),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -22),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),

            iconImageView.widthAnchor.constraint(equalToConstant: 26),
            iconImageView.heightAnchor.constraint(equalToConstant: 26)
        ])

        layer.shadowColor = UIColor(red: 0.545, green: 0.361, blue: 0.965, alpha: 0.1).cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 6)
        layer.shadowRadius = 12

        alpha = 0
        transform = CGAffineTransform(translationX: 0, y: -50)
    }

    @MainActor
    static func show(message: String, iconName: String = "checkmark.circle.fill", duration: TimeInterval = 2.0) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow })
        else {
            return
        }

        let notification = CapsuleNotification()
        notification.label.text = message
        notification.iconImageView.image = UIImage(systemName: iconName)
        notification.translatesAutoresizingMaskIntoConstraints = false

        window.addSubview(notification)

        NSLayoutConstraint.activate([
            notification.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            notification.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: 10),
            notification.widthAnchor.constraint(lessThanOrEqualTo: window.widthAnchor, multiplier: 0.9)
        ])

        // Animate In
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            notification.alpha = 1
            notification.transform = .identity
        } completion: { _ in
            // Animate Out
            UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseIn) {
                notification.alpha = 0
                notification.transform = CGAffineTransform(translationX: 0, y: -20)
            } completion: { _ in
                notification.removeFromSuperview()
            }
        }
    }
}
