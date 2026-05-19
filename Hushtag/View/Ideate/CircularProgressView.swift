import UIKit

@IBDesignable
class CircularProgressView: UIView {

    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()
    private var percentageLabel = UILabel()

    private var currentProgress: Float = 0.0

    let progressColor = UIColor(named: "AccentColor")

    var trackColor: UIColor = .systemGray5

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        percentageLabel.frame = bounds
        percentageLabel.textAlignment = .center
        percentageLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        percentageLabel.textColor = progressColor
        addSubview(percentageLabel)

        self.backgroundColor = .clear
        self.layer.cornerRadius = self.frame.size.width / 2
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        createCircularPath()
    }

    private func createCircularPath() {
        trackLayer.removeFromSuperlayer()
        progressLayer.removeFromSuperlayer()

        let circularPath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0),
                                        radius: (frame.size.width - 4) / 2,
                                        startAngle: CGFloat(-Double.pi / 2),
                                        endAngle: CGFloat(3 * Double.pi / 2),
                                        clockwise: true)

        trackLayer.path = circularPath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = 4.0
        trackLayer.strokeEnd = 1.0
        layer.addSublayer(trackLayer)

        progressLayer.path = circularPath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor?.cgColor ?? CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        progressLayer.lineWidth = 4.0
        progressLayer.lineCap = .round

        progressLayer.strokeEnd = CGFloat(currentProgress)

        layer.addSublayer(progressLayer)
        bringSubviewToFront(percentageLabel)
    }

    func setProgress(value: Float) {

        currentProgress = value
        percentageLabel.text = "\(Int(value * 100))%"

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progressLayer.strokeEnd = CGFloat(value)
        CATransaction.commit()
    }
}
