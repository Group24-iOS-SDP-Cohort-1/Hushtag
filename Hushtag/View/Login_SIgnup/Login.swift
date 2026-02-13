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
        
        enableKeyboardDismissOnTap()
        
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
            LoadingOverlay.shared.show()
            
            do {
                let user = try await viewModel.signInWithEmail(email: email, password: password)
                
                self.appUser = user
                //self.navigateToHomeScreen()
                self.navigateBasedOnOnboardingStatus()
                
            } catch let error as LocalizedError {
                LoadingOverlay.shared.hide()
                self.showAlert(title: "Login Failed", message: error.localizedDescription)
                
            } catch {
                LoadingOverlay.shared.hide()
                self.showAlert(title: "Login Failed", message: AuthError.unknown.localizedDescription)
                
            }
        }
        
        
    }
    
    
    @IBAction func googleLoginTapped(_ sender: Any) {
        
        _Concurrency.Task { @MainActor in
            LoadingOverlay.shared.show()
            do {
                let user = try await viewModel.signInWithGoogle()
                
                self.appUser = user
                //self.navigateToHomeScreen()
                self.navigateBasedOnOnboardingStatus()
                
            } catch let error as LocalizedError {
                LoadingOverlay.shared.hide()
                self.showAlert(title: "Login Failed", message: error.localizedDescription)
                
            } catch {
                LoadingOverlay.shared.hide()
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

// MARK: - EXTENSIONS

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
        ) { _ in
            LoadingOverlay.shared.hide()
        }
    }
    
    
    func navigateToLoginScreen() {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else {
                return
            }

            // 1. Get the Login Screen from Storyboard
            let storyboard = UIStoryboard(name: "login_signup", bundle: nil)
            
            // IMPORTANT: Make sure your Login View Controller has the Storyboard ID "LoginVC"
            // If your Login screen is inside a Navigation Controller, use that ID instead.
        
        guard let loginNav = storyboard.instantiateViewController(withIdentifier: "LoginNavigationController") as? UINavigationController else {
                print("Error: Could not find LoginNavigationController in Storyboard")
                return
            }

            // 2. Swap the root view controller with an animation
            //window.rootViewController = loginVC
            window.rootViewController = loginNav
            
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
            
            // 3. Make it visible
            window.makeKeyAndVisible()
        }
    
    
    
    func navigateToPreferencesScreen() {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else {
                return
            }

            // 1. Load the specific Storyboard
            let storyboard = UIStoryboard(name: "Preferences", bundle: nil)
            
            // 2. Instantiate the Initial View Controller
            // Ensure your Preferences VC is marked as "Is Initial View Controller" in that storyboard
            guard let preferencesVC = storyboard.instantiateInitialViewController() else {
                print("Error: Could not find Initial View Controller in Preferences.storyboard")
                return
            }

            // 3. Swap the root
            window.rootViewController = preferencesVC
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil) { _ in
                LoadingOverlay.shared.hide()
            }
            window.makeKeyAndVisible()
        }
    
    
    
    
    func navigateBasedOnOnboardingStatus() {
        _Concurrency.Task { @MainActor in
            let isComplete = await AuthManager.shared.hasCompletedOnboarding()
            
            // UI updates must happen on Main Thread
            
                if isComplete {
                    await SessionManager.shared.restoreSession()
                    self.navigateToHomeScreen()
                } else {
                    self.navigateToPreferencesScreen()
                }
            
        }
    }
}
