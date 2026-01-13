//
//  ViewAllScriptsCell.swift
//  Hushtag
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class ViewAllScriptsCell: UICollectionViewCell {
    
    @IBOutlet weak var Title: UILabel!
    
    @IBOutlet weak var Description: UILabel!
    
    @IBOutlet weak var Hashtag: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.15
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 6
        self.backgroundColor = .white
        Title.font = .systemFont(ofSize: 14, weight: .regular)
        Title.numberOfLines = 3
        Description.numberOfLines = 2
        Description.textColor = .secondaryLabel
}

    func configureCell(idea : Idea) {
        Title.text = idea.title
        Description.text = idea.description
        Hashtag.text = idea.hashtag.map { "#\($0)" }.joined(separator: " ")
        Hashtag.textColor = .accent
    }
}
