//
//  PreferencesHeaderView.swift
//  Hushtag
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class PreferencesHeaderView: UICollectionReusableView {

    
    @IBOutlet weak var headerLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureHeader(text : String){
        headerLabel.text = text
        headerLabel.isHidden = text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
}
