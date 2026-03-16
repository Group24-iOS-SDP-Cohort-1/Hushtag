//
//  PlatformCellTableViewCell.swift
//  Hushtag
//
//  Created by SDC-USER on 16/03/26.
//

import UIKit

class PlatformCellTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!

    @IBOutlet weak var view: UIView!

    @IBOutlet weak var youtubebtn: UIButton!

    @IBOutlet weak var instagrambtn: UIButton!

    @IBOutlet weak var twitterbtn: UIButton!

    private var allButtons: [UIButton] = []
    private var selectedButton: UIButton?
    var onPlatformSelected: ((String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        label.numberOfLines = 3
        view.backgroundColor = UIColor.systemGray4
        label.textColor = .white
        view.layer.cornerRadius = 16
        allButtons = [youtubebtn, instagrambtn, twitterbtn]
        allButtons.forEach { $0.addTarget(self, action: #selector(platformTapped(_:)), for: .touchUpInside) }

    }

    @objc func platformTapped(_ sender: UIButton) {
        guard sender != selectedButton else { return }
        allButtons.forEach {
            $0.backgroundColor = UIColor.systemGray4
            $0.setTitleColor(.white, for: .normal)
        }
        sender.backgroundColor = UIColor.accent
        sender.setTitleColor(.white, for: .normal)
        selectedButton = sender
        let platform = sender.currentTitle ?? ""
        onPlatformSelected?(platform)
    }
}
