
import UIKit

class LoadingOverlay {
    static let shared = LoadingOverlay()
    
    private var overlayView: UIView?
    private var activityIndicator: UIActivityIndicatorView?
    
    private init() {}
    
    @MainActor
    func show() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return
        }
        
        if overlayView != nil { return } // Already showing
        
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
        
        self.overlayView = overlay
        self.activityIndicator = indicator
    }
    
    @MainActor
    func hide() {
        overlayView?.removeFromSuperview()
        overlayView = nil
        activityIndicator = nil
    }
}
