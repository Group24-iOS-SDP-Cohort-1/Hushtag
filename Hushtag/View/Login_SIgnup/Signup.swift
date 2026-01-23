//
//  Signup.swift
//  Hushtag
//
//  Created by SDC-USER on 08/01/26.
//

import UIKit

class Signup: UIViewController {

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
            }

            @IBAction func signupTapped(_ sender: UIButton) {
                guard
                    let email = emailTextField.text, !email.isEmpty,
                    let password = passwordTextField.text, !password.isEmpty,
                    let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty
                else {
                    showAlert("All fields are required")
                    return
                }

                guard password == confirmPassword else {
                    showAlert("Passwords do not match")
                    return
                }

                _Concurrency.Task {
                    let success = await authController.signup(
                        email: email,
                        password: password
                    )

                    if success {
                        showAlert("Account created successfully 🎉")
                    } else {
                        showAlert("Signup failed. Try again.")
                    }
                }
            }

            private func styleSocialButton(_ button: UIButton) {
                button.backgroundColor = UIColor(white: 0.95, alpha: 1)
                button.layer.cornerRadius = 14
                button.clipsToBounds = true
            }

            private func styleTextField(_ textField: UITextField) {
                textField.layer.cornerRadius = 12
                textField.clipsToBounds = true
                textField.layer.borderWidth = 0.2
                textField.layer.borderColor = UIColor.white.cgColor
                textField.backgroundColor = .black
                textField.textColor = .white
            }

            private func showAlert(_ message: String) {
                let alert = UIAlertController(
                    title: "Signup",
                    message: message,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            }
        }
