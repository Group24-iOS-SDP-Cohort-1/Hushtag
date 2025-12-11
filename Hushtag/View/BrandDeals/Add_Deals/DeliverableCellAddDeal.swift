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
        selectionStyle = .none

                // Card look
                cardView.layer.cornerRadius = 16
                cardView.layer.masksToBounds = true
                cardView.layer.borderWidth = 0.5
                cardView.layer.borderColor = UIColor.systemGray4.cgColor

                // Button style
                addButton.setTitle("+ Deliverables", for: .normal)
    }
    private func renumberPlaceholders() {
        for (i, tv) in deliverableTextViews.enumerated() {

            let newPlaceholder = "Deliverable \(i + 1)"

            // If textView still shows placeholder text → update it
            if tv.textColor == .secondaryLabel {
                tv.text = newPlaceholder
            }

            // Always update placeholder reference
            tv.accessibilityLabel = newPlaceholder
        }
    }
    
    func configure(initialPlaceholders: [String]) {
            
            guard deliverableTextViews.isEmpty else { return }

            for placeholder in initialPlaceholders {
                addDeliverableField(placeholder: placeholder)
            }
        }

        /// Add a deliverable row (UITextView + date button + delete button)
        func addDeliverableField(placeholder: String) {
            // 1) multi-line text view
            let tv = UITextView()
            tv.text = placeholder
            tv.textColor = .secondaryLabel        // placeholder style
            tv.font = UIFont.systemFont(ofSize: 16)
            //tv.isScrollEnabled = false            // auto-expand in stack
            tv.backgroundColor = .clear
            tv.accessibilityLabel = placeholder 
            tv.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
            tv.textContainerInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
            tv.delegate = self

            // 2) date button (calendar icon)
            let dateBtn = UIButton(type: .system)
            dateBtn.setImage(UIImage(systemName: "calendar"), for: .normal)
            dateBtn.tintColor = .systemGray
            dateBtn.widthAnchor.constraint(equalToConstant: 44).isActive = true
            dateBtn.heightAnchor.constraint(equalToConstant: 44).isActive = true

            // 3) delete button (x)
            let delBtn = UIButton(type: .system)
            delBtn.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
            delBtn.tintColor = .systemRed
            delBtn.widthAnchor.constraint(equalToConstant: 36).isActive = true
            delBtn.heightAnchor.constraint(equalToConstant: 36).isActive = true

            // Make a horizontal row (text + date + delete)
            let row = UIStackView(arrangedSubviews: [tv, dateBtn, delBtn])
            row.axis = .horizontal
            row.alignment = .center
            row.distribution = .fill
            row.spacing = 8

            // textview should expand, buttons hug
            tv.setContentHuggingPriority(.defaultLow, for: .horizontal)
            dateBtn.setContentHuggingPriority(.required, for: .horizontal)
            delBtn.setContentHuggingPriority(.required, for: .horizontal)

            // Insert above the final arranged subview (assume last is the + button container)
            let index = max(stackView.arrangedSubviews.count - 1, 0)
            stackView.insertArrangedSubview(row, at: index)

            // Save references in parallel arrays
            deliverableTextViews.append(tv)
            deliverableDates.append(nil)

            // Tag & actions based on current index
            let currentIndex = deliverableTextViews.count - 1
            dateBtn.tag = currentIndex
            delBtn.tag = currentIndex
            dateBtn.addTarget(self, action: #selector(dateButtonTapped(_:)), for: .touchUpInside)
            delBtn.addTarget(self, action: #selector(deleteTapped(_:)), for: .touchUpInside)
        }

        // MARK: - Delete

    @objc private func deleteTapped(_ sender: UIButton) {
        let idx = sender.tag
        guard idx >= 0 && idx < deliverableTextViews.count else { return }

        // remove row UI
        guard let row = sender.superview as? UIStackView else { return }
        stackView.removeArrangedSubview(row)
        row.removeFromSuperview()

        // remove data
        deliverableTextViews.remove(at: idx)
        if idx < deliverableDates.count { deliverableDates.remove(at: idx) }

        // retag buttons
        retagButtons()

        // 🔥 NEW: renumber all placeholders
        renumberPlaceholders()

        // notify VC
        delegate?.deliverableCell(self, didRemoveAt: idx)
    }
        private func retagButtons() {
            var currentIndex = 0
            for sub in stackView.arrangedSubviews {
                // We expect rows to be UIStackView with (textView, dateBtn, delBtn)
                guard let row = sub as? UIStackView else { continue }
                // ensure row has at least an action button at index 1
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

        // MARK: - Date Picker

        @objc private func dateButtonTapped(_ sender: UIButton) {
            let index = sender.tag
            showDatePicker(for: index, senderButton: sender)
        }

        private func showDatePicker(for index: Int, senderButton: UIButton) {
            // Keep arrays in sync
            while deliverableDates.count < deliverableTextViews.count {
                deliverableDates.append(nil)
            }

            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .dateAndTime
            if #available(iOS 14.0, *) {
                datePicker.preferredDatePickerStyle = .inline
            }

            // restore previously selected if any
            if index < deliverableDates.count, let existing = deliverableDates[index] {
                datePicker.date = existing
            }

            // Wrap picker into a VC so we can control size
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
                senderButton.setTitle(self.shortDateString(from: selected), for: .normal)
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

        // MARK: - Exposed values for parent VC

        var deliverablesText: [String] {
            deliverableTextViews.map { $0.text ?? "" }
        }

        var deliverablesDates: [Date?] {
            deliverableDates
        }

        // MARK: - UITextViewDelegate

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

        // MARK: - Helpers

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
