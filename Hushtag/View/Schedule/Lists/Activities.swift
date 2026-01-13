//
//  Activities.swift
//  Hushtag
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit

class Activities: UIViewController {
    var scheduleItems: [ScheduleItem] = []
    var onTasksUpdated: (([Task]) -> Void)?
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

        listingView.dataSource = self
        listingView.delegate = self
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
                case .task(let task):
                    return task.isCompleted
                case .post(let post):
                    return post.isCompleted
                case .deal(let deal):
                    let total = deal.deliverable.count
                    let completed = deal.deliverable.filter { $0.isCompleted }.count
                    return total > 0 && completed == total
                }
            }
        }
    }
}

extension Activities: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scheduleItems.isEmpty ? 1 : visibleItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if scheduleItems.isEmpty {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "blankCell",
                for: indexPath
            ) as! BlankScheduleTableViewCell
            return cell
        }
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "taskCell",
            for: indexPath
        ) as! TasksTableViewCell

        let item = visibleItems[indexPath.row]
        cell.delegate = self

        switch item {
        case .task(let task):
            cell.configureCell(task, nil, nil)

        case .post(let post):
            cell.configureCell(nil, nil, post)

        case .deal(let deal):
            cell.configureCell(nil, deal, nil)
        }

        return cell
    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if  scheduleItems.isEmpty {
//            return 100
//        }
//        return 55
//    }
}

extension Activities: TasksTableViewCellDelegate {

    func didTapOpenModal(task: Task?, deal: Deal?, post: Post?) {
        let storyboard = UIStoryboard(name: "Activities", bundle: nil)
        let modal = storyboard.instantiateViewController(withIdentifier: "Details") as! Details
        modal.task = task
        modal.deal = deal
        modal.post = post
        present(modal, animated: true)
    }

    func didUpdateCompletion(task: Task?, deal: Deal?, post: Post?) {

        if let task = task {
            if let index = scheduleItems.firstIndex(where: {
                if case .task(let t) = $0 { return t.id == task.id }
                return false
            }) {
                scheduleItems[index] = .task(task)
            }
        }

        if let post = post {
            if let index = scheduleItems.firstIndex(where: {
                if case .post(let p) = $0 { return p.id == post.id }
                return false
            }) {
                scheduleItems[index] = .post(post)
            }
        }

        // deals similar if needed

        listingView.reloadData()
    }
}

