//
//  HeaderView.swift
//  Hushtag
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class HeaderView: UICollectionReusableView {

    @IBOutlet weak var headerView: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configureHeader(text:String){
        headerView.text = text
    }
}
