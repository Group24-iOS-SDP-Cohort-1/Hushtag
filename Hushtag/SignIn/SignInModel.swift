//
//  SignInModel.swift
//  Hushtag
//
//  Created by SDC-USER on 23/01/26.
//

import Foundation


class SignInModel {
    
    func isFormValid(email: String, password: String) -> Bool {
        guard email.isValidEmail(), password.count > 7 else {
            return false
        }
        return true
    }
    
    func registerNewUserWithEmail(email: String, password: String) async throws -> AppUser {
        if isFormValid(email: email, password: password){
            return try await AuthManager.shared.registerNewUserWithEmail(email: email, password: password)
        } else {
            print("Registration Form is invalid")
            throw NSError()
        }
    }
    
    func signInWithEmail(email: String, password: String) async throws -> AppUser {
        if isFormValid(email: email, password: password){
            return try await AuthManager.shared.signInWithEmail(email: email, password: password)
        } else {
            print("Sign in Form is invalid")
            throw NSError()
        }
    }
    
}


extension String {
    
    func isValidEmail() -> Bool {

        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: self)

    }
    
}
