//
//  TasksTableViewCell.swift
//  Hushtag
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class TasksTableViewCell: UITableViewCell {
    var onDetailsTap: ((Task?, Deal?, Post?) -> Void)?
    private var task: Task?
    private var deal: Deal?
    private var post: Post?
    @IBOutlet weak var nameLabel: UILabel!
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
    }
    
    @IBAction func radioPressed(_ sender: UIButton) {
        isChecked.toggle()  // flip state
        
        let imageName = isChecked ? "circle.inset.filled" : "circle"
        sender.setImage(UIImage(systemName: imageName), for: .normal)
    }
    @IBAction func detailsButtonPressed(_ sender: UIButton) {
        onDetailsTap?(task, deal, post)
    }
    
}
