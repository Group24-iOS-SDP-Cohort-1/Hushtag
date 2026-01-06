//
//  IdeaSearch.swift
//  Hushtag
//
//  Created by SDC-USER on 17/12/25.
//

import UIKit

protocol IdeaSearchDelegate: AnyObject {
    func didTapSearch(with keyword: String)
}

class IdeaSearch: UICollectionReusableView {

    @IBOutlet weak var textView: UIView!
    
    @IBOutlet weak var textLabel: UITextField!
    
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var textStack: UIStackView!
    
    
    @IBOutlet weak var crossButton: UIButton!
    
    weak var delegate: IdeaSearchDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.layer.borderColor = UIColor.accent.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        crossButton.isHidden = true
        
    }
    
    @IBAction func searchTap(_ sender: UIButton) {
        let keyword = textLabel.text ?? ""
        textStack.isHidden = true
        crossButton.isHidden = false
        delegate?.didTapSearch(with: keyword)
    }
    
    
    @IBAction func crossTap(_ sender: UIButton) {
        textLabel.text = ""
        textStack.isHidden = false
        crossButton.isHidden = true
        delegate?.didTapSearch(with: "")
    }
}
    
    

