import UIKit

class LoadingOverlay {
    static let shared = LoadingOverlay()

    private var overlayView: UIView?
    private var activityIndicator: UIActivityIndicatorView?

    private init() {}

    @MainActor
    func show() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow })
        else {
            return
        }

        if overlayView != nil { return }

        let overlay = UIView(frame: window.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.center = overlay.center
        indicator.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        indicator.startAnimating()

        overlay.addSubview(indicator)
        window.addSubview(overlay)

        overlayView = overlay
        activityIndicator = indicator
    }

    @MainActor
    func hide() {
        overlayView?.removeFromSuperview()
        overlayView = nil
        activityIndicator = nil
    }
}

class OpaqueLoadingScreen {
    static let shared = OpaqueLoadingScreen()

    private var overlayView: UIView?
    private var activityIndicator: UIActivityIndicatorView?
    private var messageLabel: UILabel?

    private init() {}

    @MainActor
    func show(message: String = "Finding the best ideas...") {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow })
        else {
            return
        }

        if overlayView != nil { return }

        let overlay = UIView(frame: window.bounds)
        overlay.backgroundColor = UIColor.systemBackground
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let container = UIStackView()
        container.axis = .vertical
        container.alignment = .center
        container.spacing = 20
        container.translatesAutoresizingMaskIntoConstraints = false

        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .accent
        indicator.startAnimating()

        let label = UILabel()
        label.text = message
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)

        container.addArrangedSubview(indicator)
        container.addArrangedSubview(label)

        overlay.addSubview(container)
        window.addSubview(overlay)

        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: overlay.centerYAnchor)
        ])

        overlayView = overlay
        activityIndicator = indicator
        messageLabel = label
    }

    @MainActor
    func hide() {
        guard let overlay = overlayView else { return }
        UIView.animate(withDuration: 0.3, animations: {
            overlay.alpha = 0
        }) { _ in
            overlay.removeFromSuperview()
            self.overlayView = nil
            self.activityIndicator = nil
            self.messageLabel = nil
        }
    }
}
