//
//  Signup.swift
//  Hushtag
//
//  Created by SDC-USER on 08/01/26.
//

import UIKit

class Signup: UIViewController {
    
    var viewModel: SignInModel = SignInModel()
    
    var appUser: AppUser?

    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var appleButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    private let authController = AuthController()

    override func viewDidLoad() {
        super.viewDidLoad()

        styleSocialButton(googleButton)
        styleSocialButton(facebookButton)
        styleSocialButton(appleButton)
        styleTextField(emailTextField)
        styleTextField(passwordTextField)
        styleTextField(confirmPasswordTextField)
        // Do any additional setup after loading the view.
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
    
    
    @IBAction func signUpTapped(_ sender: Any) {
        
//        _Concurrency.Task{
//            do{
//                
//                guard let password = passwordTextField.text, let email = emailTextField.text else {return}
//                
//                let appUser = try await viewModel.registerNewUserWithEmail(email: email, password: password)
//                self.appUser = appUser
//                print(appUser)
//            }catch{
//                print("Issue with Sign In")
//            }
//        }
        guard let email = emailTextField.text,
                  let password = passwordTextField.text,
                  let confirmPassword = confirmPasswordTextField.text else {
                showAlert(title: "Error", message: AuthError.emptyFields.localizedDescription)
                return
            }

            guard password == confirmPassword else {
                showAlert(title: "Error", message: AuthError.passwordsDoNotMatch.localizedDescription)
                return
            }

        _Concurrency.Task { @MainActor in
                do {
                    let user = try await viewModel.registerNewUserWithEmail(email: email, password: password)

                
                        self.appUser = user
                        //self.navigateToHomeScreen()
                    self.navigateToPreferencesScreen()
                } catch let error as LocalizedError {
                        self.showAlert(title: "Signup Failed", message: error.localizedDescription)
                }
            }
        
    }
    
}
