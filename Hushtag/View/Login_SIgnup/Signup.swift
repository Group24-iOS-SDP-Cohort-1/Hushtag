//
//  Signup.swift
//  Hushtag
//
//  Created by SDC-USER on 08/01/26.
//

import UIKit

class Signup: UIViewController {
    
    var viewModel: SignInModel = SignInModel()
    
    var appUser: AppUser = AppUser(uid: "1234", email: "abc@gmail.com")

    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var appleButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
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
        
        _Concurrency.Task{
            do{
                
                guard let password = passwordTextField.text, let email = emailTextField.text else {return}
                
                let appUser = try await viewModel.registerNewUserWithEmail(email: email, password: password)
                self.appUser = appUser
                print(appUser)
            }catch{
                print("Issue with Sign In")
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
