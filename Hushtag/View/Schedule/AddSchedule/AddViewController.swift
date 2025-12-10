//
//  AddViewController.swift
//  Hushtag
//
//  Created by SDC-USER on 10/12/25.
//

import UIKit

class AddViewController: UIViewController {
    @IBOutlet weak var fieldView: UITableView!
    var category: String?
    var post: [Post]?
    var deals: [Deal]?
    var tasks: [Task]?
    override func viewDidLoad() {
        super.viewDidLoad()
        fieldView.delegate = self
        fieldView.dataSource = self
        //navigationBar.topItem?.title = category
    }
    
}

extension AddViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fieldCell", for: indexPath) as! FieldTableViewCell
        cell.configure(index: indexPath.row, category: category ?? "")
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToAddStuff", sender: indexPath.row)
    }

}
