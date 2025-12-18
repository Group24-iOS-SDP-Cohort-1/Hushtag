//
//  IdeaSearch.swift
//  Hushtag
//
//  Created by SDC-USER on 17/12/25.
//

import UIKit

class IdeaSearch: UICollectionReusableView {

    @IBOutlet weak var textView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.layer.borderColor = UIColor.accent.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
    }
    
}
