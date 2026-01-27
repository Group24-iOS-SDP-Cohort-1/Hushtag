//
//  SignInModel.swift
//  Hushtag
//
//  Created by SDC-USER on 23/01/26.
//

import Foundation


//class SignInModel {
//    
//    func isFormValid(email: String, password: String) -> Bool {
//        guard email.isValidEmail(), password.count > 7 else {
//            return false
//        }
//        return true
//    }
//    
////    func registerNewUserWithEmail(email: String, password: String) async throws -> AppUser {
////        if isFormValid(email: email, password: password){
////            return try await AuthManager.shared.registerNewUserWithEmail(email: email, password: password)
////        } else {
////            print("Registration Form is invalid")
////            throw NSError()
////        }
////    }
//    
//    
//    
////    func signInWithEmail(email: String, password: String) async throws -> AppUser {
////        if isFormValid(email: email, password: password){
////            return try await AuthManager.shared.signInWithEmail(email: email, password: password)
////        } else {
////            print("Sign in Form is invalid")
////            throw NSError()
////        }
////    }
//    
//    func registerNewUserWithEmail(email: String, password: String) async throws -> AppUser {
//        guard isFormValid(email: email, password: password) else {
//            throw AuthError.invalidForm
//        }
//        return try await AuthManager.shared.registerNewUserWithEmail(email: email, password: password)
//    }
//
//    func signInWithEmail(email: String, password: String) async throws -> AppUser {
//        guard isFormValid(email: email, password: password) else {
//            throw AuthError.invalidForm
//        }
//        return try await AuthManager.shared.signInWithEmail(email: email, password: password)
//    }
//    
//}

class SignInModel {

    private func validateForSignup(email: String, password: String) throws {

        if email.isEmpty || password.isEmpty {
            throw AuthError.emptyFields
        }

        if !email.isValidEmail() {
            throw AuthError.invalidEmail
        }

        if !password.isStrongPassword() {
            throw AuthError.weakPassword
        }
    }


    private func validateForLogin(email: String, password: String) throws {

        if email.isEmpty || password.isEmpty {
            throw AuthError.emptyFields
        }
    }


    func registerNewUserWithEmail(email: String, password: String) async throws -> AppUser {
        try validateForSignup(email: email, password: password)
        return try await AuthManager.shared.registerNewUserWithEmail(
            email: email,
            password: password
        )
    }

    func signInWithEmail(email: String, password: String) async throws -> AppUser {
        try validateForLogin(email: email, password: password)

        do {
            return try await AuthManager.shared.signInWithEmail(
                email: email,
                password: password
            )
        } catch {
            throw AuthError.invalidCredentials
        }
    }
}


extension String {

    func isValidEmail() -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailFormat)
            .evaluate(with: self)
    }

    func isStrongPassword() -> Bool {
        let passwordFormat =
        "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&#])[A-Za-z\\d@$!%*?&#]{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordFormat)
            .evaluate(with: self)
    }
}
