//
//  likedCells.swift
//  Hushtag
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

//protocol LikedCellDelegate: AnyObject {
//    func didTapDraftScript(for idea: Idea)
//}

class likedCells: UICollectionViewCell{

    @IBOutlet weak var Title: UILabel!
    @IBOutlet weak var Description: UILabel!
    @IBOutlet weak var Hashtag: UILabel!
    @IBOutlet weak var draftScript: UIButton!

    private var currentIdea: Idea?
    weak var delegate: LikedCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.15
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 6
        self.backgroundColor = .white
        // Title Label (plusLabel)
        Title.font = .systemFont(ofSize: 14, weight: .regular)
        Title.textColor = UIColor.label
        Title.numberOfLines = 3
        // Description Label
        Description.textColor = UIColor.secondaryLabel
        Description.numberOfLines = 2
        draftScript.addTarget(self, action: #selector(draftScriptTapped), for: .touchUpInside)
    }
    func configureCell(idea : Idea) {
        self.currentIdea = idea
        Title.text = idea.title
        Description.text = idea.description
        Hashtag.text = idea.hashtag.map { "#\($0)" }.joined(separator: " ")
        Hashtag.textColor = .accent
    }

    @objc private func draftScriptTapped() {
            guard let idea = currentIdea else { return }
            delegate?.didTapDraftScript(for: idea)
    }
}
