//
//  Login.swift
//  Hushtag
//
//  Created by SDC-USER on 08/01/26.
//

import UIKit

class Login: UIViewController {

    @IBOutlet weak var googleButton: UIButton!
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var appleButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!

    private let authController = AuthController()

    override func viewDidLoad() {
        super.viewDidLoad()

        styleSocialButton(googleButton)
               styleSocialButton(facebookButton)
               styleSocialButton(appleButton)
               styleTextField(emailTextField)
               styleTextField(passwordTextField)
           }



           @IBAction func loginTapped(_ sender: UIButton) {
               guard
                   let email = emailTextField.text, !email.isEmpty,
                   let password = passwordTextField.text, !password.isEmpty
               else {
                   showAlert("Email and password are required")
                   return
               }

               _Concurrency.Task {
                   let success = await authController.login(
                       email: email,
                       password: password
                   )

                   if success {
                               navigateToIdeate()   
                           } else {
                               showAlert("Login failed")
                           }

               }
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

           func showAlert(_ message: String) {
               let alert = UIAlertController(
                   title: "Login",
                   message: message,
                   preferredStyle: .alert
               )
               alert.addAction(UIAlertAction(title: "OK", style: .default))
               present(alert, animated: true)
           }

        private func navigateToIdeate() {
            let storyboard = UIStoryboard(name: "Ideate", bundle: nil)
            let ideateRootVC = storyboard.instantiateInitialViewController()

            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else {
                return
            }

            window.rootViewController = ideateRootVC
            window.makeKeyAndVisible()
    }
}
