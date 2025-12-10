//
//  TasksTableViewCell.swift
//  Hushtag
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

protocol TasksTableViewCellDelegate: AnyObject {
    func didTapOpenModal(task: Task?, deal: Deal?, post: Post?)
}

class TasksTableViewCell: UITableViewCell {
    weak var delegate: TasksTableViewCellDelegate?
    private var task: Task?
    private var deal: Deal?
    private var post: Post?
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var radioButton: UIButton!
    private var isChecked: Bool = false
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    func configureCell(_ tasks: Task?, _ deals: Deal?, _ posts: Post?) {
        self.task = tasks
        self.deal = deals
        self.post = posts

        nameLabel.text = tasks?.name ?? posts?.name ?? deals?.name ?? " "
        if tasks?.isCompleted == true || posts?.isCompleted == true {
            radioButton.setImage(UIImage(systemName: "circle.inset.filled"), for: .normal)
            nameLabel.textColor = .systemGray
        }
    }
    
    @IBAction func radioPressed(_ sender: UIButton) {
        isChecked.toggle()  // flip state
        
        let imageName = isChecked ? "circle.inset.filled" : "circle"
        nameLabel.textColor = isChecked ? .systemGray : .black
        sender.setImage(UIImage(systemName: imageName), for: .normal)
        if isChecked {
            post?.isCompleted = true
            task?.isCompleted = true
        }
    }
    @IBAction func detailsButtonPressed(_ sender: UIButton) {
        delegate?.didTapOpenModal(task: task, deal: deal, post: post)
    }
    
}

