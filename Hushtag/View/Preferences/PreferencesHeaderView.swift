//
//  PreferencesHeaderView.swift
//  Hushtag
//


import UIKit

class PreferencesHeaderView: UICollectionReusableView {
    
    
    @IBOutlet weak var headerLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configureHeader(text : String){
        headerLabel.text = text
        headerLabel.isHidden = text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
}
