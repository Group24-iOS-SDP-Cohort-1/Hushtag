//
//  IdeateSearchHeader.swift
//  Hushtag
//
//  Created by SDC-USER on 16/12/25.
//

import UIKit

class IdeateSearchHeader: UICollectionReusableView {


    @IBOutlet weak var textView: UIView!

    @IBOutlet weak var textField: UITextField!

    @IBOutlet weak var searchButton: UIButton!

    var onButtonTapped: ((String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        textView.layer.cornerRadius = 10
        textView.layer.borderWidth = 0.8
        textView.layer.borderColor = UIColor.accent.cgColor

        // Button icon
        searchButton.tintColor = .accent
        searchButton.setImage(UIImage(systemName: "sparkles"), for: .normal)

        // TextField placeholder
        textField.attributedPlaceholder = NSAttributedString(
                   string: "Enter your keyword",
                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.accent]
               )

        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
           }

           @objc func textDidChange() {

           }

           @IBAction func buttonTapped(_ sender: UIButton) {
               let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
               onButtonTapped?(text)
           }
       }
