//
//  DeliverableCellAddDeal.swift
//  Hushtag
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit
protocol DeliverableCellAddDealDelegate: AnyObject {
    func deliverableCellDidTapAdd(_ cell: DeliverableCellAddDeal)
    func deliverableCell(_ cell: DeliverableCellAddDeal, didRemoveAt index: Int)
}

class DeliverableCellAddDeal: UITableViewCell, UITextViewDelegate{
    weak var delegate: DeliverableCellAddDealDelegate?
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var stackView: UIStackView!

    @IBOutlet weak var addButton: UIButton!
    
    private var deliverableTextViews: [UITextView] = []
    private var deliverableDates: [Date?] = []
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

                // Card style
                cardView.layer.cornerRadius = 16
                cardView.layer.masksToBounds = false
                cardView.backgroundColor = .clear
                cardView.applyLiquidGlassEffect()
                // Button style
                addButton.setTitle("+ Deliverables", for: .normal)
    }
    private func renumberPlaceholders() {
        for (i, tv) in deliverableTextViews.enumerated() {

            let newPlaceholder = "Deliverable \(i + 1)"
            
            if tv.textColor == .secondaryLabel {
                tv.text = newPlaceholder
            }

            tv.accessibilityLabel = newPlaceholder
        }
    }
    
    func configure(initialPlaceholders: [String]) {
            
            guard deliverableTextViews.isEmpty else { return }

            for placeholder in initialPlaceholders {
                addDeliverableField(placeholder: placeholder)
            }
        }

       
        func addDeliverableField(placeholder: String) {
            
            let tv = UITextView()
            tv.text = placeholder
            tv.textColor = .secondaryLabel
            tv.font = UIFont.systemFont(ofSize: 16)
            tv.backgroundColor = .clear
            tv.accessibilityLabel = placeholder 
            tv.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
            tv.textContainerInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
            tv.delegate = self

            let dateBtn = UIButton(type: .system)
            dateBtn.setImage(UIImage(systemName: "calendar"), for: .normal)
            dateBtn.tintColor = .systemGray
            dateBtn.widthAnchor.constraint(equalToConstant: 44).isActive = true
            dateBtn.heightAnchor.constraint(equalToConstant: 44).isActive = true

            let delBtn = UIButton(type: .system)
            delBtn.setImage(UIImage(systemName: "minus.circle"), for: .normal)
            delBtn.tintColor = .systemRed
            delBtn.widthAnchor.constraint(equalToConstant: 20).isActive = true
            delBtn.heightAnchor.constraint(equalToConstant: 20).isActive = true

            let row = UIStackView(arrangedSubviews: [tv, dateBtn, delBtn])
            row.axis = .horizontal
            row.alignment = .center
            row.distribution = .fill
            row.spacing = 8

            tv.setContentHuggingPriority(.defaultLow, for: .horizontal)
            dateBtn.setContentHuggingPriority(.required, for: .horizontal)
            delBtn.setContentHuggingPriority(.required, for: .horizontal)

            let index = max(stackView.arrangedSubviews.count - 1, 0)
            stackView.insertArrangedSubview(row, at: index)

            deliverableTextViews.append(tv)
            deliverableDates.append(nil)

            let currentIndex = deliverableTextViews.count - 1
            dateBtn.tag = currentIndex
            delBtn.tag = currentIndex
            dateBtn.addTarget(self, action: #selector(dateButtonTapped(_:)), for: .touchUpInside)
            delBtn.addTarget(self, action: #selector(deleteTapped(_:)), for: .touchUpInside)
        }

    @objc private func deleteTapped(_ sender: UIButton) {
        let idx = sender.tag
        guard idx >= 0 && idx < deliverableTextViews.count else { return }

        guard let row = sender.superview as? UIStackView else { return }
        stackView.removeArrangedSubview(row)
        row.removeFromSuperview()

        deliverableTextViews.remove(at: idx)
        if idx < deliverableDates.count { deliverableDates.remove(at: idx) }

        retagButtons()

        renumberPlaceholders()

        delegate?.deliverableCell(self, didRemoveAt: idx)
    }
        private func retagButtons() {
            var currentIndex = 0
            for sub in stackView.arrangedSubviews {
                guard let row = sub as? UIStackView else { continue }
                if row.arrangedSubviews.count >= 2 {
                    if let dateBtn = row.arrangedSubviews.safe(1) as? UIButton {
                        dateBtn.tag = currentIndex
                    }
                    if row.arrangedSubviews.count > 2, let delBtn = row.arrangedSubviews.safe(2) as? UIButton {
                        delBtn.tag = currentIndex
                    }
                    currentIndex += 1
                }
            }
        }

        @objc private func dateButtonTapped(_ sender: UIButton) {
            let index = sender.tag
            showDatePicker(for: index, senderButton: sender)
        }

        private func showDatePicker(for index: Int, senderButton: UIButton) {
            while deliverableDates.count < deliverableTextViews.count {
                deliverableDates.append(nil)
            }

            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .dateAndTime
            if #available(iOS 14.0, *) {
                datePicker.preferredDatePickerStyle = .inline
            }

            if index < deliverableDates.count, let existing = deliverableDates[index] {
                datePicker.date = existing
            }

            let contentVC = UIViewController()
            contentVC.view.addSubview(datePicker)
            datePicker.translatesAutoresizingMaskIntoConstraints = false

            let minWidth: CGFloat = 320
            NSLayoutConstraint.activate([
                datePicker.leadingAnchor.constraint(equalTo: contentVC.view.leadingAnchor),
                datePicker.trailingAnchor.constraint(equalTo: contentVC.view.trailingAnchor),
                datePicker.topAnchor.constraint(equalTo: contentVC.view.topAnchor),
                datePicker.bottomAnchor.constraint(equalTo: contentVC.view.bottomAnchor),
                datePicker.widthAnchor.constraint(greaterThanOrEqualToConstant: minWidth),
                contentVC.view.widthAnchor.constraint(greaterThanOrEqualToConstant: minWidth)
            ])

            contentVC.preferredContentSize = CGSize(width: minWidth, height: 340)

            let alert = UIAlertController(title: "Select date & time", message: nil, preferredStyle: .actionSheet)
            alert.setValue(contentVC, forKey: "contentViewController")

            alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                let selected = datePicker.date
                // store single date for this index
                if index < self.deliverableDates.count {
                    self.deliverableDates[index] = selected
                } else {
                    while self.deliverableDates.count <= index { self.deliverableDates.append(nil) }
                    self.deliverableDates[index] = selected
                }
                senderButton.setTitle(nil, for: .normal)
                senderButton.setImage(UIImage(systemName: "calendar"), for: .normal)
                senderButton.tintColor = UIColor(red: 139/255, green: 92/255, blue: 246/255, alpha: 1)
            }))

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            if let vc = parentViewController() {
                if let presented = vc.presentedViewController as? UIAlertController {
                    presented.dismiss(animated: false) {
                        if let pop = alert.popoverPresentationController {
                            pop.sourceView = senderButton
                            pop.sourceRect = senderButton.bounds
                            pop.permittedArrowDirections = [.up, .down]
                        }
                        vc.present(alert, animated: true, completion: nil)
                    }
                } else {
                    if let pop = alert.popoverPresentationController {
                        pop.sourceView = senderButton
                        pop.sourceRect = senderButton.bounds
                        pop.permittedArrowDirections = [.up, .down]
                    }
                    vc.present(alert, animated: true, completion: nil)
                }
            }
        }

        private func shortDateString(from date: Date) -> String {
            let df = DateFormatter()
            df.dateFormat = "dd MMM, h:mm a"
            return df.string(from: date)
        }

        var deliverablesText: [String] {
            deliverableTextViews.map { $0.text ?? "" }
        }

        var deliverablesDates: [Date?] {
            deliverableDates
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.textColor == .secondaryLabel {
                textView.text = ""
                textView.textColor = .label
            }
        }

        func textViewDidChange(_ textView: UITextView) {
            // auto resize
            textView.sizeToFit()
            layoutIfNeeded()
        }

        private func parentViewController() -> UIViewController? {
            var parentResponder: UIResponder? = self
            while parentResponder != nil {
                parentResponder = parentResponder?.next
                if let vc = parentResponder as? UIViewController { return vc }
            }
            return nil
        }

    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        delegate?.deliverableCellDidTapAdd(self)
    }
    

}
