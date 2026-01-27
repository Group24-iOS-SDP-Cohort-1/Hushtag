//
//  Login.swift
//  Hushtag
//
//  Created by SDC-USER on 08/01/26.
//

import UIKit

class Login: UIViewController {
    
    var viewModel: SignInModel = SignInModel()
    
    var appUser: AppUser?

    @IBOutlet weak var googleButton: UIButton!
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var appleButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        styleSocialButton(googleButton)
        styleSocialButton(facebookButton)
        styleSocialButton(appleButton)
        styleTextField(emailTextField)
        styleTextField(passwordTextField)
    }
    
    func styleSocialButton(_ button: UIButton) {
        button.backgroundColor = UIColor(white: 0.95, alpha: 1)
        button.layer.cornerRadius = 14
        button.clipsToBounds = true
    }
    
    func styleTextField(_ textField: UITextField) {
        textField.layer.cornerRadius = 12
        textField.clipsToBounds = true
        textField.layer.borderWidth = 0.2
        textField.layer.borderColor = UIColor.white.cgColor
        textField.backgroundColor = .black
        textField.textColor = .white
    }
    
    
    @IBAction func logInTapped(_ sender: Any) {
//        _Concurrency.Task{
//            do{
//                
//                guard let password = passwordTextField.text, let email = emailTextField.text else {return}
//                
//                let appUser = try await viewModel.signInWithEmail(email: email, password: password)
//                self.appUser = appUser
//                print(appUser)
//            }catch{
//                print("Issue with Sign In")
//            }
//        }
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
                showAlert(title: "Error", message: AuthError.emptyFields.localizedDescription)
                return
            }

        _Concurrency.Task { @MainActor in
                do {
                    let user = try await viewModel.signInWithEmail(email: email, password: password)

                        self.appUser = user
                        self.navigateToHomeScreen()

                } catch let error as LocalizedError {
                    
                        self.showAlert(title: "Login Failed", message: error.localizedDescription)
                    
                } catch {
                    
                        self.showAlert(title: "Login Failed", message: AuthError.unknown.localizedDescription)
                    
                }
            }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


// From here we are generating an alert with text ok

extension UIViewController{
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    
    func navigateToHomeScreen() {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first else {
                return
            }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBar = storyboard.instantiateViewController(
            withIdentifier: "MainTabBarController"
        )

        window.rootViewController = mainTabBar
        window.makeKeyAndVisible()

        UIView.transition(
            with: window,
            duration: 0.25,
            options: .transitionCrossDissolve,
            animations: nil
        )
    }
}
