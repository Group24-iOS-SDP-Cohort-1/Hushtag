//
//  SuggestionCell.swift
//  Hushtag
//
//  Created by SDC-USER on 10/12/25.
//

import UIKit

class SuggestionCell: UICollectionReusableView {


    @IBOutlet weak var suggestionButton: UIButton!

    var tapHandler: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        suggestionButton.addTarget(self, action: #selector(btnTapped), for: .touchUpInside)
    }


    @IBAction func btnTapped(_ sender: Any) {
        tapHandler?()
    }

    func configure(markedAs: String) {
        switch markedAs.lowercased() {
        case "script":
            suggestionButton.setTitle("Generate Title", for: .normal)

        case "title":
            suggestionButton.setTitle("Generate Description", for: .normal)

        case "description":
            suggestionButton.setTitle("Generate Thumbnail", for: .normal)

        case "thumbnail":
            suggestionButton.setTitle("Thumbnail Finalized", for: .normal)
            suggestionButton.isEnabled = false

        default:
            suggestionButton.setTitle("", for: .normal)
        }

    }
}
