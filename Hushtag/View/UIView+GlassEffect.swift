import UIKit

extension UIView {
    
    /**
     Applies a UIGlassEffect to the view as a background.
     
     This function inserts a UIVisualEffectView at index 0, constrains it
     to the edges of this view, and animates the glass effect.
     It also matches the corner radius.
    */
    func applyLiquidGlassEffect() {
        
        // --- Safety Check ---
        // To prevent adding multiple effect views if called by accident,
        // we can check if one already exists.
        let existingGlassView = self.subviews.first { $0 is UIVisualEffectView }
        if existingGlassView != nil {
            return // Already has a glass effect
        }

        // --- Your Code, Modified ---
        
        // Create the visual effect view
        let glassEffectView = UIVisualEffectView()
        glassEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add it to 'self' (the view this is called on)
        self.insertSubview(glassEffectView, at: 0)
        
        // Pin the glass effect view to all edges of 'self'
        NSLayoutConstraint.activate([
            glassEffectView.topAnchor.constraint(equalTo: self.topAnchor),
            glassEffectView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            glassEffectView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            glassEffectView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        // Create and apply the glass effect with animation
        let glassEffect = UIGlassEffect()
        UIView.animate(withDuration: 0.3) {
            glassEffectView.effect = glassEffect
        }
        
        // Match corner radius of 'self'
        glassEffectView.layer.cornerRadius = self.layer.cornerRadius
        glassEffectView.clipsToBounds = true
    }
}
