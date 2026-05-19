import UIKit

class WelcomeViewController: UIViewController {
    @IBOutlet var signUp: UIButton!
    @IBOutlet var loginButton: UIButton!

    @IBAction func signUpTapped(_: UIButton) {
        print("Register tapped")
    }

    @IBAction func loginTapped(_: UIButton) {
        print("Login tapped")
    }
}
