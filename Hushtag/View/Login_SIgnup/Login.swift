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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
