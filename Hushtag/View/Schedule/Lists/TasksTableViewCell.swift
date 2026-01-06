//
//  TasksTableViewCell.swift
//  Hushtag
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

protocol TasksTableViewCellDelegate: AnyObject {
    func didTapOpenModal(task: Task?, deal: Deal?, post: Post?)
    func didUpdateCompletion(task: Task?, deal: Deal?, post: Post?)
}

class TasksTableViewCell: UITableViewCell {
    weak var delegate: TasksTableViewCellDelegate?
    private var task: Task?
    private var deal: Deal?
    private var post: Post?

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var radioButton: UIButton!
    
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
        nameLabel.text = " "
        updateUI(isCompleted: false)
    }
    
    func configureCell(_ task: Task?, _ deal: Deal?, _ post: Post?) {
        self.task = task
        self.deal = deal
        self.post = post

        nameLabel.text = task?.name ?? post?.name ?? deal?.name ?? ""

        let isCompleted =
            task?.isCompleted == true ||
            post?.isCompleted == true
            // deal?.isCompleted == true

        updateUI(isCompleted: isCompleted)
    }
    
    @IBAction func radioPressed(_ sender: UIButton) {
        let newValue = !(
            task?.isCompleted == true ||
            post?.isCompleted == true
        )

        task?.isCompleted = newValue
        post?.isCompleted = newValue
        // deal?.isCompleted = newValue

        updateUI(isCompleted: newValue)

        delegate?.didUpdateCompletion(task: task, deal: deal, post: post)
    }
    @IBAction func detailsButtonPressed(_ sender: UIButton) {
        delegate?.didTapOpenModal(task: task, deal: deal, post: post)
    }
    private func updateUI(isCompleted: Bool) {
        let imageName = isCompleted ? "circle.inset.filled" : "circle"
        radioButton.setImage(UIImage(systemName: imageName), for: .normal)
        nameLabel.textColor = isCompleted ? .systemGray : .label
    }
}

