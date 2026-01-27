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
            return scheduleItems.filter { item in
                switch item {
                case .deal(_, let deliverable):
                    return deliverable.isCompleted
                case .post(_, let task):
                    return task.isCompleted
                }
            }
        }
    }
}
