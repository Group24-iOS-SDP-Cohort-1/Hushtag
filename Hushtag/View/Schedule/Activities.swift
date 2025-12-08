//
//  Activities.swift
//  Hushtag
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit

class Activities: UIViewController {
    var tasks: [Task]?
    var posts: [Post]?
    var deals: [Deal]?

    @IBOutlet weak var listingView: UITableView!
    var category: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        listingView.dataSource = self
        listingView.delegate = self
        switch category {
            case "Tasks":
                self.title = "Tasks"
            case "Deals":
                self.title = "Deals"
            case "Posts":
                self.title = "Posts"
            default:
                self.title = "Activities"
        }
    }
}

extension Activities: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch category {
        case "Tasks":
            return tasks?.count ?? 0
        case "Posts":
            return posts?.count ?? 0
        case "Deals":
            return deals?.count ?? 0
        default:
            break
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch category {

        case "Tasks":
            let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TasksTableViewCell
            guard let task = tasks?[indexPath.row] else { return UITableViewCell() }
            cell.configureCell(task, nil, nil)
            return cell

        case "Posts":
            let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TasksTableViewCell
            guard let post = posts?[indexPath.row] else { return UITableViewCell() }
            cell.configureCell(nil, nil, post)
            return cell

        case "Deals":
            let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TasksTableViewCell
            guard let deal = deals?[indexPath.row] else { return UITableViewCell() }
            cell.configureCell(nil, deal, nil)
            return cell

        default:
            return UITableViewCell()
        }

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
}
