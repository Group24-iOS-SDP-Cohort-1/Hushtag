//
//  TabBarController.swift
//  Hushtag
//
//  Created by SDC-USER on 13/11/25.
//

import UIKit
class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        if let viewControllers = self.viewControllers {
            viewControllers[1].tabBarItem.title = "Workplace"
            viewControllers[1].tabBarItem.image = UIImage(systemName: "folder")
            
            viewControllers[0].tabBarItem.title = "Ideate"
            viewControllers[0].tabBarItem.image = UIImage(systemName: "sparkles.2")

            viewControllers[2].tabBarItem.title = "Deals"
            viewControllers[2].tabBarItem.image = UIImage(systemName: "list.bullet")
        }
    }
}
