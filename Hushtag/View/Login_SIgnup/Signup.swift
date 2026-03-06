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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleSocialButton(googleButton)
        styleSocialButton(facebookButton)
        styleSocialButton(appleButton)
        styleTextField(emailTextField)
        styleTextField(passwordTextField)
        styleTextField(confirmPasswordTextField)
        
        enableKeyboardDismissOnTap()
        
        googleButton.addTarget(self, action: #selector(googleSignUpTapped), for: .touchUpInside)
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
        
        Task { @MainActor in
            LoadingOverlay.shared.show()
            do {
                let user = try await viewModel.registerNewUserWithEmail(email: email, password: password)
                
                
                self.appUser = user
                self.navigateToPreferencesScreen()
            } catch let error as LocalizedError {
                LoadingOverlay.shared.hide()
                self.showAlert(title: "Signup Failed", message: error.localizedDescription)
            } catch {
                LoadingOverlay.shared.hide()
                self.showAlert(title: "Signup Failed", message: "An unknown error occurred")
            }
        }
        
    }
    
    
    @IBAction func googleSignUpTapped(_ sender: UIButton) {
        Task { @MainActor in
            LoadingOverlay.shared.show()
            
            defer { LoadingOverlay.shared.hide() }
            
            do {
                
                let user = try await viewModel.signInWithGoogle()
                
                self.appUser = user
                
                self.navigateBasedOnOnboardingStatus()
                
            } catch let error as LocalizedError {
                //LoadingOverlay.shared.hide()
                self.showAlert(title: "Sign Up Failed", message: error.localizedDescription)
                
            } catch {
                //LoadingOverlay.shared.hide()
                self.showAlert(title: "Sign Up Failed", message: AuthError.unknown.localizedDescription)
                
            }
        }
    }
    
}
