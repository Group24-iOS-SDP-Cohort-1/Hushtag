//
//  TasksTableViewCell.swift
//  Hushtag
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

protocol TasksTableViewCellDelegate: AnyObject {
    func didTapOpenModal(deal: Deal?, post: Post?)
    func didUpdateCompletion(deal: Deal?, post: Post?)
}

class TasksTableViewCell: UITableViewCell {
    weak var delegate: TasksTableViewCellDelegate?
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
        deal = nil
        post = nil
        nameLabel.text = ""
        updateUI(isCompleted: false)
    }

    func configureCell(deal: Deal?, post: Post?) {
        self.deal = deal
        self.post = post

        nameLabel.text = post?.name ?? deal?.name ?? ""

        let isCompleted: Bool
        if let post {
            isCompleted = post.tasks?.allSatisfy { $0.isCompleted } ?? false
        } else if let deal {
            isCompleted = deal.deliverable.allSatisfy { $0.isCompleted }
        } else {
            isCompleted = false
        }

        updateUI(isCompleted: isCompleted)
    }
    
    @IBAction func radioPressed(_ sender: UIButton) {
        if var post = post {
            let newValue = !(post.tasks?.allSatisfy { $0.isCompleted } ?? false)
            post.tasks?.indices.forEach { post.tasks?[$0].isCompleted = newValue }
            self.post = post
        }

        if var deal = deal {
            let newValue = !deal.deliverable.allSatisfy { $0.isCompleted }
            deal.deliverable.indices.forEach { deal.deliverable[$0].isCompleted = newValue }
            self.deal = deal
        }

        let updatedCompletion = post?.tasks?.allSatisfy { $0.isCompleted } ?? deal?.deliverable.allSatisfy { $0.isCompleted } ?? false

        updateUI(isCompleted: updatedCompletion)

        delegate?.didUpdateCompletion(deal: deal, post: post)
    }
    @IBAction func detailsButtonPressed(_ sender: UIButton) {
        delegate?.didTapOpenModal(deal: deal, post: post)
    }
    private func updateUI(isCompleted: Bool) {
        let imageName = isCompleted ? "circle.inset.filled" : "circle"
        radioButton.setImage(UIImage(systemName: imageName), for: .normal)
        nameLabel.textColor = isCompleted ? .systemGray : .label
    }
}

