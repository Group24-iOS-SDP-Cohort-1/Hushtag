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

    var onSearchTriggered: ((String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
}
