import UIKit

final class CardBackgroundView: UICollectionReusableView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {

        backgroundColor = UIColor.white.withAlphaComponent(0.06)
        layer.masksToBounds = true
        applyLiquidGlassEffect()
    }
}
