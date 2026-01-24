//
//  Activities.swift
//  Hushtag
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit

class Activities: UIViewController {
    var scheduleItems: [ScheduleItem] = []
    var onDealsUpdated: (([Deal]) -> Void)?
    var onPostsUpdated: (([Post]) -> Void)?
    enum ActivityFilter {
        case all
        case completed
    }
    var filter: ActivityFilter = .all

    @IBOutlet weak var listingView: UITableView!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    var category: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listingView.register(
            UINib(nibName: "BlankScheduleTableViewCell", bundle: nil),
            forCellReuseIdentifier: "blankCell"
        )
        listingView.reloadData()
    }
    private var visibleItems: [ScheduleItem] {
        switch filter {
        case .all:
            return scheduleItems
        case .completed:
            return scheduleItems.filter {
                switch $0 {
                case .post(let post):
                    let total = post.tasks?.count ?? 0
                    let completed = post.tasks?.filter { $0.isCompleted }.count ?? 0
                    return total > 0 && completed == total
                case .deal(let deal):
                    let total = deal.deliverables.count
                    let completed = deal.deliverables.filter { $0.isCompleted }.count
                    return total > 0 && completed == total
                }
            }
        }
    }
}
