import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var signUp: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        print("Register tapped")
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        print("Login tapped")
    }
}
