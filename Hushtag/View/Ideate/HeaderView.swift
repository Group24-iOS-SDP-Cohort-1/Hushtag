//
//  HeaderView.swift
//  Hushtag
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class HeaderView: UICollectionReusableView {

    @IBOutlet weak var HeaderView: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configureHeader(text:String){
        HeaderView.text = text
    }
}
