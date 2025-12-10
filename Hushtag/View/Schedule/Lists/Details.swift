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
    }
}

extension Details: UITableViewDelegate, UITableViewDataSource {
    func numberOfFields(for object: Any?) -> Int {
        guard let object else { return 0 }
        let mirror = Mirror(reflecting: object)
        return mirror.children.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailsTableViewCell
        cell.configure(task: task, deal: deal, post: post, index: indexPath.row)
        return cell
    }
}
