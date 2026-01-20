//
//  CalendarCell.swift
//  Hushtag
//
//  Created by SDC-USER on 13/01/26.
//

import UIKit

class CalendarCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    private var swipeLeft: UISwipeGestureRecognizer!
    private var swipeRight: UISwipeGestureRecognizer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 12
        setupGestures()
    }

    func configure(day: String, date: String, isSelected: Bool) {
        dayLabel.text = day
        dateLabel.text = date
        if isSelected {
            contentView.backgroundColor = .accent
            dayLabel.textColor = .white
            dateLabel.textColor = .white
        } else {
            contentView.backgroundColor = .clear
            dayLabel.textColor = .lightGray
            dateLabel.textColor = .white
        }
    }
    
    private func setupGestures() {
        swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        swipeLeft.delegate = self

        swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        swipeRight.delegate = self

        contentView.addGestureRecognizer(swipeLeft)
        contentView.addGestureRecognizer(swipeRight)

        contentView.isUserInteractionEnabled = true
    }

    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        guard let collectionView = contentView.findCollectionView(),
              collectionView.indexPath(for: self) != nil else { return }

        switch gesture.direction {
        case .left:
            NotificationCenter.default.post(name: .calendarSwipeLeft, object: nil)
        case .right:
            NotificationCenter.default.post(name: .calendarSwipeRight, object: nil)
        default:
            break
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension UIView {
    func findCollectionView() -> UICollectionView? {
        var view = self.superview
        while view != nil {
            if let cv = view as? UICollectionView {
                return cv
            }
            view = view?.superview
        }
        return nil
    }
}
