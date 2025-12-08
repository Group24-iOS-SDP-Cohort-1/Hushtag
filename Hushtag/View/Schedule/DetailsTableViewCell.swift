//
//  DetailsTableViewCell.swift
//  Hushtag
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class DetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configure(post: Post?) {
        print("3", post)
        
        valueLabel.text = post?.name ?? ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
