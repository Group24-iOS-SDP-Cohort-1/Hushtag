//
//  TasksTableViewCell.swift
//  Hushtag
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

protocol TasksTableViewCellDelegate: AnyObject {
    func didTapOpenModal(task: Task?, deal: Deal?, post: Post?)
    func didUpdateCompletion(at indexPath: IndexPath, task: Task?, deal: Deal?, post: Post?)
}

class TasksTableViewCell: UITableViewCell {
    weak var delegate: TasksTableViewCellDelegate?
    private var task: Task?
    private var deal: Deal?
    private var post: Post?
    var indexPath: IndexPath?
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var radioButton: UIButton!
    private var isChecked: Bool = false {
        didSet { updateUIForCheckedState() }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        radioButton.contentMode = .scaleAspectFit
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset to a known state so reused cells don't show stale UI
        task = nil
        post = nil
        deal = nil
        indexPath = nil
        nameLabel.text = " "
        isChecked = false
    }
    
    func configureCell(_ tasks: Task?, _ deals: Deal?, _ posts: Post?) {
        self.task = tasks
        self.deal = deals
        self.post = posts

        nameLabel.text = tasks?.name ?? posts?.name ?? deals?.name ?? " "
        let taskCompleted = tasks?.isCompleted
        let postCompleted = posts?.isCompleted
        //let dealCompleted = deals?.isCompleted

        // If any model has completed = true, consider checked
        self.isChecked = (taskCompleted == true) || (postCompleted == true) /*|| (dealCompleted == true)*/
    }
    
    @IBAction func radioPressed(_ sender: UIButton) {
        isChecked.toggle()  // flip state
        
        self.post?.isCompleted = isChecked
        self.task?.isCompleted = isChecked
        //self.deal?.isCompleted = isChecked

        if let indexPath = indexPath {
            delegate?.didUpdateCompletion(at: indexPath, task: task, deal: deal, post: post)
        }

    }
    @IBAction func detailsButtonPressed(_ sender: UIButton) {
        delegate?.didTapOpenModal(task: task, deal: deal, post: post)
    }
    private func updateUIForCheckedState() {
        // set image and label color based on isChecked
        let imageName = isChecked ? "circle.inset.filled" : "circle"
        radioButton.setImage(UIImage(systemName: imageName), for: .normal)
        nameLabel.textColor = isChecked ? .systemGray : .black
    }
}

