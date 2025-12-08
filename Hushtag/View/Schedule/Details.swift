//
//  Details.swift
//  Hushtag
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class Details: UIViewController {

    var task: Task?
    var deal: Deal?
    var post: Post?
    
    @IBOutlet weak var infoView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        infoView.delegate = self
        infoView.dataSource = self
        navigationItem.title = task?.name ?? post?.name ?? deal?.name ?? "Details"
        
    }
}

extension Details: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailsTableViewCell
        cell.configure(task: task, deal: deal, post: post)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
}
