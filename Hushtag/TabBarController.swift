import UIKit
class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        if let viewControllers = self.viewControllers {
            viewControllers[0].tabBarItem.title = "Ideate"
            viewControllers[0].tabBarItem.image = UIImage(systemName: "sparkles.2")
            
            viewControllers[1].tabBarItem.title = "Analysis"
            viewControllers[1].tabBarItem.image = UIImage(systemName: "chart.bar.xaxis")
            
            viewControllers[2].tabBarItem.title = "Deals"
            viewControllers[2].tabBarItem.image = UIImage(systemName: "list.bullet")
            
            viewControllers[3].tabBarItem.title = "Schedule"
            viewControllers[3].tabBarItem.image = UIImage(systemName: "calendar")
        }
    }
}
