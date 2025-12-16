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
    var onTasksUpdated: (([Task]) -> Void)?
    var onDealsUpdated: (([Deal]) -> Void)?
    var onPostsUpdated: (([Post]) -> Void)?


    @IBOutlet weak var listingView: UITableView!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    var category: String?
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    
    @IBAction func buttonPressed(_ sender: UIBarButtonItem) {
        guard let category = category else { return }

            if category == "Deals" {
                
                let storyboard = UIStoryboard(name: "BrandDeals", bundle: nil)
                guard let addDealsVC = storyboard.instantiateViewController(withIdentifier: "AddDealsViewController") as? AddDealsViewController else {
                    return
                }

                // configure
                addDealsVC.delegate = self
                addDealsVC.InputDeal = nil
                addDealsVC.title = "Add Deal"

                // wrap so nav items appear
                let nav = UINavigationController(rootViewController: addDealsVC)
                nav.modalPresentationStyle = .automatic
                present(nav, animated: true, completion: nil)
                return
            }

            // For Tasks / Posts -> present AddViewController (reuse existing add VC)
            let storyboard = UIStoryboard(name: "Activities", bundle: nil)
            guard let addVC = storyboard.instantiateViewController(withIdentifier: "AddViewController") as? AddViewController else {
                print("⚠️ Could not instantiate AddViewController - check Storyboard ID and storyboard name")
                return
            }

            addVC.category = category
            addVC.delegate = self

            // pass existing arrays so AddVC can show current items if needed
            if category == "Tasks" { addVC.tasks = tasks }
            else if category == "Posts" { addVC.post = posts }

            // wrap in nav controller so Save/Cancel nav items show (if you use them)
            let nav = UINavigationController(rootViewController: addVC)
            nav.modalPresentationStyle = .automatic
            present(nav, animated: true, completion: nil)

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAddStuff" {
            // If AddViewController is embedded in a UINavigationController when presented modally,
            // you might need to get topViewController
            if let nav = segue.destination as? UINavigationController,
               let vc = nav.topViewController as? AddViewController {
                vc.category = category
                vc.delegate = self
                if category == "Tasks" { vc.tasks = tasks }
                else if category == "Deals" { vc.deals = deals }
                else if category == "Posts" { vc.post = posts }
            } else if let vc = segue.destination as? AddViewController {
                vc.category = category
                vc.delegate = self
                if category == "Tasks" { vc.tasks = tasks }
                else if category == "Deals" { vc.deals = deals }
                else if category == "Posts" { vc.post = posts }
            }
        }
    }
}

extension Activities: UITableViewDataSource, UITableViewDelegate{
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
            cell.indexPath = indexPath
            cell.delegate = self
            return cell

        case "Posts":
            let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TasksTableViewCell
            guard let post = posts?[indexPath.row] else { return UITableViewCell() }
            cell.configureCell(nil, nil, post)
            cell.indexPath = indexPath
            cell.delegate = self
            return cell

        case "Deals":
            let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TasksTableViewCell
            guard let deal = deals?[indexPath.row] else { return UITableViewCell() }
            cell.configureCell(nil, deal, nil)
            cell.indexPath = indexPath
            cell.delegate = self
            return cell

        default:
            return UITableViewCell()
        }

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
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
    func didUpdateCompletion(at indexPath: IndexPath, task: Task?, deal: Deal?, post: Post?) {
        switch category {
        case "Tasks":
            if let updated = task {
                tasks?[indexPath.row] = updated
                onTasksUpdated?(tasks ?? [])
            }
            
        case "Posts":
            if let updated = post {
                posts?[indexPath.row] = updated
                onPostsUpdated?(posts ?? [])
            }
            
//        case "Deals":
//            if let updated = deal {
//                deals?[indexPath.row] = updated
//                onDealsUpdated?(deals ?? [])
//            }
            
        default: break
        }

        listingView.reloadRows(at: [indexPath], with: .automatic)
    }



}

extension Activities: AddViewControllerDelegate {
    func addViewController(_ controller: AddViewController, didAddTask task: Task) {
        if tasks == nil { tasks = [] }
        tasks?.append(task)
        listingView.reloadData()
        onTasksUpdated?(tasks ?? [])
    }

    func addViewController(_ controller: AddViewController, didAddDeal deal: Deal) {
        if deals == nil { deals = [] }
        deals?.append(deal)
        listingView.reloadData()
        onDealsUpdated?(deals ?? [])
    }

    func addViewController(_ controller: AddViewController, didAddPost post: Post) {
        if posts == nil { posts = [] }
        posts?.append(post)
        listingView.reloadData()
        onPostsUpdated?(posts ?? [])
    }
}
extension Activities: AddDealsDelegate {
    func addDealsViewController(_ controller: AddDealsViewController, didCreateDeal deal: Deal) {
        if deals == nil { deals = [] }
        deals?.append(deal)

        // Insert row with animation (if your listingView has one section)
        let newIndex = (deals?.count ?? 1) - 1
        listingView.beginUpdates()
        listingView.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: .automatic)
        listingView.endUpdates()

        // Notify any external observers
        onDealsUpdated?(deals ?? [])
    }
}
