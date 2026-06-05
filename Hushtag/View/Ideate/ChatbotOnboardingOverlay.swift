import UIKit

// MARK: - Touch Blocker
// Passes touches through only inside `passThroughRect` (the highlighted cell).

private final class OnboardingTouchBlockerView: UIView {
    var passThroughRect: CGRect = .zero
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        passThroughRect.contains(point) ? nil : super.hitTest(point, with: event)
    }
}

// MARK: - ChatbotOnboardingOverlay

final class ChatbotOnboardingOverlay {

    // MARK: - Persistence

    static let tutorialCompletedKey = "hasCompletedContentSelectionTutorial"

    static var isCompleted: Bool {
        get { UserDefaults.standard.bool(forKey: tutorialCompletedKey) }
        set { UserDefaults.standard.set(newValue, forKey: tutorialCompletedKey) }
    }

    // MARK: - Callbacks

    var onDidActivate: (() -> Void)?
    var onCompleted: (() -> Void)?

    // MARK: - Private State

    private weak var hostView: UIView?
    private weak var highlightedBubble: UIView?   // chatView inside the cell

    // Saved original layer values to restore on dismiss
    private var originalShadowOpacity: Float = 0
    private var originalShadowRadius: CGFloat = 0
    private var originalBorderWidth: CGFloat = 0

    private var blockerView: OnboardingTouchBlockerView?
    private var tooltipWrapper: UIView?
    private var successCard: UIView?

    private var cellContentRect: CGRect = .zero   // in hostView coordinates

    // MARK: - Entry Point

    /// Pass the live `ChatCell` — we apply the glow directly to `cell.chatView`.
    func present(in hostView: UIView, cell: ChatCell) {
        guard let bubbleView = cell.chatView else { return }

        self.hostView = hostView
        self.highlightedBubble = bubbleView

        // Convert cell content frame to hostView coordinates (for touch blocker)
        cellContentRect = cell.contentView.superview?
            .convert(cell.contentView.frame, to: hostView) ?? .zero

        applyGlow(to: bubbleView)
        addTouchBlocker(in: hostView)
        showTooltip(in: hostView, below: bubbleView)

        onDidActivate?()
    }

    // MARK: - Glow on the bubble

    private func applyGlow(to view: UIView) {
        // Save originals
        originalShadowOpacity = view.layer.shadowOpacity
        originalShadowRadius  = view.layer.shadowRadius
        originalBorderWidth   = view.layer.borderWidth

        // Apply glow
        view.layer.shadowColor   = UIColor.accent.cgColor
        view.layer.shadowOpacity = 0.85
        view.layer.shadowRadius  = 18
        view.layer.shadowOffset  = .zero
        view.layer.borderWidth   = 2.0
        view.layer.borderColor   = UIColor.accent.withAlphaComponent(0.8).cgColor
        view.clipsToBounds       = false

        // Breathing pulse on shadow radius
        let pulseRadius = CABasicAnimation(keyPath: "shadowRadius")
        pulseRadius.fromValue  = 18
        pulseRadius.toValue    = 30
        pulseRadius.duration   = 1.0
        pulseRadius.autoreverses = true
        pulseRadius.repeatCount  = .infinity
        pulseRadius.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        view.layer.add(pulseRadius, forKey: "glowRadius")

        let pulseOpacity = CABasicAnimation(keyPath: "shadowOpacity")
        pulseOpacity.fromValue  = 0.85
        pulseOpacity.toValue    = 0.30
        pulseOpacity.duration   = 1.0
        pulseOpacity.autoreverses = true
        pulseOpacity.repeatCount  = .infinity
        pulseOpacity.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        view.layer.add(pulseOpacity, forKey: "glowOpacity")
    }

    private func removeGlow(from view: UIView) {
        view.layer.removeAnimation(forKey: "glowRadius")
        view.layer.removeAnimation(forKey: "glowOpacity")
        view.layer.shadowOpacity = originalShadowOpacity
        view.layer.shadowRadius  = originalShadowRadius
        view.layer.borderWidth   = originalBorderWidth
        view.layer.borderColor   = UIColor.white.cgColor
    }

    // MARK: - Touch Blocker

    private func addTouchBlocker(in hostView: UIView) {
        let blocker = OnboardingTouchBlockerView(frame: hostView.bounds)
        blocker.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        blocker.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blocker.passThroughRect = cellContentRect
        blocker.alpha = 0
        hostView.addSubview(blocker)
        self.blockerView = blocker
        UIView.animate(withDuration: 0.3) { blocker.alpha = 1 }
    }

    // MARK: - Tooltip popup with arrow

    private func showTooltip(in hostView: UIView, below bubbleView: UIView) {
        guard let bubbleFrame = bubbleView.superview?.convert(bubbleView.frame, to: hostView) else { return }

        // Wrapper view holds card + arrow together so they animate/dismiss as one
        let wrapper = UIView()
        wrapper.backgroundColor = .clear
        wrapper.isUserInteractionEnabled = false
        wrapper.alpha = 0
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        hostView.addSubview(wrapper)
        self.tooltipWrapper = wrapper

        // --- Blurred tooltip card (sits ABOVE the bubble) ---
        let card = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        card.layer.cornerRadius = 16
        card.clipsToBounds = true
        card.layer.borderWidth = 1.2
        card.layer.borderColor = UIColor.accent.withAlphaComponent(0.55).cgColor
        card.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(card)

        let tint = UIView()
        tint.backgroundColor = UIColor(red: 0.545, green: 0.361, blue: 0.965, alpha: 0.18)
        tint.translatesAutoresizingMaskIntoConstraints = false
        card.contentView.addSubview(tint)

        let icon = UIImageView(image: UIImage(systemName: "hand.point.up.left.fill"))
        icon.tintColor = UIColor.accent
        icon.contentMode = .scaleAspectFit
        icon.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        icon.setContentHuggingPriority(.required, for: .horizontal)

        let label = UILabel()
        label.text = "Long press this message to mark it as Script, Title, or Description"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [icon, label])
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .top
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.contentView.addSubview(stack)

        // --- Arrow triangle points DOWN toward the bubble below ---
        let arrowW: CGFloat = 20
        let arrowH: CGFloat = 10
        let arrowContainer = UIView()
        arrowContainer.backgroundColor = .clear
        arrowContainer.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(arrowContainer)

        let arrowShape = CAShapeLayer()
        let arrowPath = UIBezierPath()
        arrowPath.move(to: CGPoint(x: 0, y: 0))           // top-left
        arrowPath.addLine(to: CGPoint(x: arrowW, y: 0))   // top-right
        arrowPath.addLine(to: CGPoint(x: arrowW / 2, y: arrowH)) // bottom-center point
        arrowPath.close()
        arrowShape.path = arrowPath.cgPath
        arrowShape.fillColor = UIColor(red: 0.18, green: 0.12, blue: 0.32, alpha: 0.97).cgColor
        arrowContainer.layer.addSublayer(arrowShape)

        // Clamp arrow horizontally to the bubble's midX
        let clampedMidX = min(max(bubbleFrame.midX, 40), hostView.bounds.width - 40)
        let arrowLeadingOffset = clampedMidX - 16 - arrowW / 2

        // The tooltip stays at the top of the screen (under nav bar) safely
        NSLayoutConstraint.activate([
            wrapper.topAnchor.constraint(equalTo: hostView.safeAreaLayoutGuide.topAnchor, constant: 16),
            wrapper.leadingAnchor.constraint(equalTo: hostView.leadingAnchor, constant: 16),
            wrapper.trailingAnchor.constraint(equalTo: hostView.trailingAnchor, constant: -16),

            // Card at top of wrapper
            card.topAnchor.constraint(equalTo: wrapper.topAnchor),
            card.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),

            // Arrow below the card, overlapping by 1pt
            arrowContainer.topAnchor.constraint(equalTo: card.bottomAnchor, constant: -1),
            arrowContainer.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
            arrowContainer.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: arrowLeadingOffset),
            arrowContainer.widthAnchor.constraint(equalToConstant: arrowW),
            arrowContainer.heightAnchor.constraint(equalToConstant: arrowH),

            tint.topAnchor.constraint(equalTo: card.topAnchor),
            tint.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            tint.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            tint.bottomAnchor.constraint(equalTo: card.bottomAnchor),

            stack.topAnchor.constraint(equalTo: card.contentView.topAnchor, constant: 14),
            stack.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor, constant: -14),
            stack.bottomAnchor.constraint(equalTo: card.contentView.bottomAnchor, constant: -14),

            icon.widthAnchor.constraint(equalToConstant: 26),
            icon.heightAnchor.constraint(equalToConstant: 26)
        ])

        UIView.animate(withDuration: 0.3, delay: 0.25) { wrapper.alpha = 1 }
    }

    // MARK: - Called by Chatbot after successful mark

    func notifyUserCompletedSelection() {
        showSuccessAndDismiss()
    }

    // MARK: - Dismiss

    func dismiss() {
        if let bubble = highlightedBubble { removeGlow(from: bubble) }
        UIView.animate(withDuration: 0.25, animations: {
            self.blockerView?.alpha = 0
            self.tooltipWrapper?.alpha = 0
            self.successCard?.alpha = 0
        }, completion: { _ in
            self.blockerView?.removeFromSuperview()
            self.tooltipWrapper?.removeFromSuperview()
            self.successCard?.removeFromSuperview()
            self.blockerView = nil
            self.tooltipWrapper = nil
            self.successCard = nil
        })
    }

    // MARK: - Success State

    private func showSuccessAndDismiss() {
        guard let hostView = hostView else { return }
        ChatbotOnboardingOverlay.isCompleted = true

        // Remove glow and dismiss tooltip/blocker
        if let bubble = highlightedBubble { removeGlow(from: bubble) }
        UIView.animate(withDuration: 0.2) {
            self.blockerView?.alpha = 0
            self.tooltipWrapper?.alpha = 0
        } completion: { _ in
            self.blockerView?.removeFromSuperview()
            self.tooltipWrapper?.removeFromSuperview()
            self.blockerView = nil
            self.tooltipWrapper = nil
        }

        // Success card
        let card = buildSuccessCard()
        card.alpha = 0
        card.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
        card.translatesAutoresizingMaskIntoConstraints = false
        hostView.addSubview(card)
        self.successCard = card

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: hostView.safeAreaLayoutGuide.topAnchor, constant: 16),
            card.leadingAnchor.constraint(equalTo: hostView.leadingAnchor, constant: 24),
            card.trailingAnchor.constraint(equalTo: hostView.trailingAnchor, constant: -24)
        ])

        UIView.animate(withDuration: 0.4, delay: 0,
                       usingSpringWithDamping: 0.72,
                       initialSpringVelocity: 0.5,
                       options: []) {
            card.alpha = 1
            card.transform = .identity
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            UIView.animate(withDuration: 0.3, animations: { card.alpha = 0 }) { _ in
                card.removeFromSuperview()
                self?.successCard = nil
                self?.onCompleted?()
            }
        }
    }

    private func buildSuccessCard() -> UIView {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        blur.layer.cornerRadius = 22
        blur.clipsToBounds = true
        blur.layer.borderWidth = 1.2
        blur.layer.borderColor = UIColor.accent.withAlphaComponent(0.55).cgColor

        let tint = UIView()
        tint.backgroundColor = UIColor.accent.withAlphaComponent(0.12)
        tint.translatesAutoresizingMaskIntoConstraints = false
        blur.contentView.addSubview(tint)

        let checkIcon = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        checkIcon.tintColor = UIColor.accent
        checkIcon.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 34, weight: .semibold)
        checkIcon.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.text = "You're all set!"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textAlignment = .center

        let bodyLabel = UILabel()
        bodyLabel.text = "You can long press any AI message anytime to save it as a Script, Title, or Description."
        bodyLabel.textColor = UIColor.white.withAlphaComponent(0.78)
        bodyLabel.font = UIFont.systemFont(ofSize: 14)
        bodyLabel.numberOfLines = 0
        bodyLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [checkIcon, titleLabel, bodyLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        blur.contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            tint.topAnchor.constraint(equalTo: blur.topAnchor),
            tint.leadingAnchor.constraint(equalTo: blur.leadingAnchor),
            tint.trailingAnchor.constraint(equalTo: blur.trailingAnchor),
            tint.bottomAnchor.constraint(equalTo: blur.bottomAnchor),

            stack.topAnchor.constraint(equalTo: blur.contentView.topAnchor, constant: 28),
            stack.leadingAnchor.constraint(equalTo: blur.contentView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: blur.contentView.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: blur.contentView.bottomAnchor, constant: -28),

            checkIcon.widthAnchor.constraint(equalToConstant: 44),
            checkIcon.heightAnchor.constraint(equalToConstant: 44)
        ])

        return blur
    }
}
