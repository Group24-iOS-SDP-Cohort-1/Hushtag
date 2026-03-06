import UIKit

extension UIView {
    
    func applyLiquidGlassEffect() {
        if subviews.contains(where: { $0 is UIVisualEffectView }) {
            return
        }
        if #available(iOS 17.0, *) {
            applyGlassEffect_iOS17()
        } else {
            applyCardEffect_Legacy()
        }
    }
}

@available(iOS 17.0, *)
private extension UIView {
    
    func applyGlassEffect_iOS17() {
        let glassView = UIVisualEffectView(effect: nil)
        glassView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(glassView, at: 0)
        
        NSLayoutConstraint.activate([
            glassView.topAnchor.constraint(equalTo: topAnchor),
            glassView.leadingAnchor.constraint(equalTo: leadingAnchor),
            glassView.trailingAnchor.constraint(equalTo: trailingAnchor),
            glassView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // FIXED: Use standard UIBlurEffect instead of possibly missing 'UIGlassEffect'
        let glassEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        UIView.animate(withDuration: 0.25) {
            glassView.effect = glassEffect
        }
        
        glassView.layer.cornerRadius = 12
        glassView.clipsToBounds = true
    }
}

private extension UIView {
    
    func applyCardEffect_Legacy() {
        
        backgroundColor = UIColor.secondarySystemBackground
        
        layer.cornerRadius = 12
        layer.masksToBounds = false
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 4)
        
        // Optional subtle blur overlay
        let blur = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(blurView, at: 0)
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        blurView.layer.cornerRadius = 12
        blurView.clipsToBounds = true
    }
}
