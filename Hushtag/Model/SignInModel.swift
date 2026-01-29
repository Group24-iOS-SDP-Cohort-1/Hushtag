//
//  SignInModel.swift
//  Hushtag
//
//  Created by SDC-USER on 23/01/26.
//

import Foundation
import GoogleSignIn

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
            print("DEBUG ERROR: \(error)")
            throw AuthError.invalidCredentials
        }
    }
    
    
    
    func signInWithGoogle() async throws -> AppUser {
        let signInGoogle = SignInGoogle()
        let googleResult = try await signInGoogle.startSignInWithGoogleFlow()
        return try await AuthManager.shared.signInWithGoogle(idToken: googleResult.idToken)
        
    }
}




struct SignInGoogleResult{
    let idToken: String
}

class SignInGoogle {
    
    func startSignInWithGoogleFlow() async throws -> SignInGoogleResult {
        try await withCheckedThrowingContinuation({ [weak self] continuation in
            self?.signInWithGoogleFlow { result in
                continuation.resume(with: result)
            }
        })
    }
    
    func signInWithGoogleFlow(completion: @escaping (Result<SignInGoogleResult, Error>) -> Void) {
        
        guard let topVC = UIApplication.topViewController else{
            completion(.failure(NSError()))
            return
        }
        
        GIDSignIn.sharedInstance.signIn(
            withPresenting: topVC
        ) { signInResult, error in
            guard let user = signInResult?.user, let idToken = user.idToken else {
                // Inspect error
                completion(.failure(NSError()))
                print("Error signing in: \(error?.localizedDescription ?? "No error description")")
                return
            }
            completion(.success(.init(idToken: idToken.tokenString)))
        }
    }
}




extension UIApplication {
    static var topViewController: UIViewController? {
        guard let root = UIApplication.shared
            .connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?
            .rootViewController
        else { return nil }
        
        var top = root
        while let presented = top.presentedViewController {
            top = presented
        }
        return top
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
