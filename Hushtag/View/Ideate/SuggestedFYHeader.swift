//
//  SuggestedFYHeader.swift
//  Hushtag
//
//  Created by SDC-USER on 06/01/26.
//

import UIKit

class SuggestedFYHeader: UICollectionReusableView {

    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        label.text = "Suggested For You"
    }

}
