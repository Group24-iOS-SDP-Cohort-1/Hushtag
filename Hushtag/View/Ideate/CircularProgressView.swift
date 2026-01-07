////
////  CircularProgressView.swift
////  Hushtag
////
////  Created by SDC-USER on 18/12/25.



import UIKit

@IBDesignable
class CircularProgressView: UIView {
    
    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()
    private var percentageLabel = UILabel()
    
    // 1. Add a variable to store the value so we don't lose it during layout updates
    private var currentProgress: Float = 0.0
    
    //var progressColor: UIColor = .systemBlue
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
        // This method runs whenever the cell size is calculated.
        // We redraw the path to match the new size.
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
        
        // Track Layer
        trackLayer.path = circularPath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = 4.0
        trackLayer.strokeEnd = 1.0
        layer.addSublayer(trackLayer)
        
        // Progress Layer
        progressLayer.path = circularPath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor?.cgColor ?? CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        progressLayer.lineWidth = 4.0
        progressLayer.lineCap = .round
        
        // 2. IMPORTANT: Use the stored value when redrawing!
        progressLayer.strokeEnd = CGFloat(currentProgress)
        
        layer.addSublayer(progressLayer)
        bringSubviewToFront(percentageLabel)
    }
    
    func setProgress(value: Float) {
        // 3. Save the state
        currentProgress = value
        percentageLabel.text = "\(Int(value * 100))%"
        
        // 4. Disable the default "growing" animation for instant appearance
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progressLayer.strokeEnd = CGFloat(value)
        CATransaction.commit()
    }
}










//@IBDesignable
//class CircularProgressView: UIView {
//
//    private var progressLayer = CAShapeLayer()
//    private var trackLayer = CAShapeLayer()
//    private var percentageLabel = UILabel()
//
//    // customizable colors
//    var progressColor: UIColor = .systemBlue
//    var trackColor: UIColor = .systemGray5
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupView()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupView()
//    }
//
//    private func setupView() {
//        // Setup Label (e.g., "50%")
//        percentageLabel.frame = bounds
//        percentageLabel.textAlignment = .center
//        percentageLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular) // Adjust font size as needed
//        percentageLabel.textColor = progressColor
//        addSubview(percentageLabel)
//
//        // Make the background transparent
//        self.backgroundColor = .clear
//        self.layer.cornerRadius = self.frame.size.width / 2
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        // Redraw layers when layout changes
//        createCircularPath()
//    }
//
//    private func createCircularPath() {
//        // Remove old layers to prevent duplicates if layout changes
//        trackLayer.removeFromSuperlayer()
//        progressLayer.removeFromSuperlayer()
//
//        let circularPath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0),
//                                        radius: (frame.size.width - 4) / 2, // -4 gives it some padding
//                                        startAngle: CGFloat(-Double.pi / 2),
//                                        endAngle: CGFloat(3 * Double.pi / 2),
//                                        clockwise: true)
//
//        // Track Layer (Grey background ring)
//        trackLayer.path = circularPath.cgPath
//        trackLayer.fillColor = UIColor.clear.cgColor
//        trackLayer.strokeColor = trackColor.cgColor
//        trackLayer.lineWidth = 4.0
//        trackLayer.strokeEnd = 1.0
//        layer.addSublayer(trackLayer)
//
//        // Progress Layer (Blue foreground ring)
//        progressLayer.path = circularPath.cgPath
//        progressLayer.fillColor = UIColor.clear.cgColor
//        progressLayer.strokeColor = progressColor.cgColor
//        progressLayer.lineWidth = 4.0
//        progressLayer.strokeEnd = 0.0 // Initial value
//        progressLayer.lineCap = .round
//        layer.addSublayer(progressLayer)
//
//        // Bring label to front
//        bringSubviewToFront(percentageLabel)
//    }
//
//    func setProgress(value: Float) {
//        progressLayer.strokeEnd = CGFloat(value)
//        percentageLabel.text = "\(Int(value * 100))%"
//    }
//}
