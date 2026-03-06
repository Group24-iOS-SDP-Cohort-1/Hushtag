import Foundation
import GoogleSignIn


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
            //print("DEBUG ERROR: \(error)")
            throw AuthError.invalidCredentials
        }
    }
    
    
    
    func signInWithGoogle() async throws -> AppUser {
        let signInGoogle = SignInGoogle()
        let googleResult = try await signInGoogle.startSignInWithGoogleFlow()
        
        let user = try await AuthManager.shared.signInWithGoogle(idToken: googleResult.idToken)
        
        if let serverAuthCode = googleResult.serverAuthCode, !serverAuthCode.isEmpty {
            do {
                try await YouTubeController.shared.saveYouTubeTokens(
                    serverAuthCode: serverAuthCode
                )
            } catch {
                //print("Failed to save YouTube tokens during Google Sign-In: \(error)")
            }
        }
        
        return user
    }
    
    
    func connectYouTube() async throws {
        let signInGoogle = SignInGoogle()
        let youtubeResult = try await signInGoogle.startConnectYouTubeFlow()
        
        try await YouTubeController.shared.saveYouTubeTokens(
            serverAuthCode: youtubeResult.serverAuthCode
        )
    }
    
    func disconnectYouTube() {
        
        GIDSignIn.sharedInstance.disconnect { error in
            if let error = error {
                //print("Failed to disconnect Google: \(error.localizedDescription)")
            } else {
                //print("Successfully disconnected from Google")
            }
        }
        
    }
}






struct SignInGoogleResult {
    let idToken: String
    let serverAuthCode: String?
}

struct ConnectYouTubeResult {
    let serverAuthCode: String
}

class SignInGoogle {
    
    @MainActor
    func startSignInWithGoogleFlow() async throws -> SignInGoogleResult {
        try await withCheckedThrowingContinuation({ continuation in
            self.signInWithGoogleFlow { result in
                continuation.resume(with: result)
            }
        })
    }
    
    @MainActor
    func signInWithGoogleFlow(completion: @escaping (Result<SignInGoogleResult, Error>) -> Void) {
        
        guard let topVC = UIApplication.topViewController else{
            let error = NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not find the top view controller."])
            
            completion(.failure(error))
            return
        }
        
        
        
        GIDSignIn.sharedInstance.signIn(
            withPresenting: topVC,
            hint: nil,
            additionalScopes: ["https://www.googleapis.com/auth/yt-analytics.readonly", "https://www.googleapis.com/auth/youtube.readonly"]
        ) { signInResult, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = signInResult?.user, let idToken = user.idToken else {
                
                let tokenError = NSError(domain: "AuthError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve Google ID Token."])
                
                completion(.failure(tokenError))
                //print("Error signing in: \(error?.localizedDescription ?? "No error description")")
                return
            }
            
            let accessToken = user.accessToken.tokenString
            let refreshToken = user.refreshToken.tokenString
            let serverAuthCode = signInResult?.serverAuthCode
            
            completion(.success(.init(
                idToken: idToken.tokenString,
                serverAuthCode: serverAuthCode
            )))
        }
    }
    
    
    
    @MainActor
    func startConnectYouTubeFlow() async throws -> ConnectYouTubeResult {
        try await withCheckedThrowingContinuation({ continuation in
            self.connectYouTubeFlow { result in
                continuation.resume(with: result)
            }
        })
    }
    
    @MainActor
    func connectYouTubeFlow(completion: @escaping (Result<ConnectYouTubeResult, Error>) -> Void) {
        
        guard let topVC = UIApplication.topViewController else{
            let error = NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not find the top view controller."])
            completion(.failure(error))
            return
        }
        
        GIDSignIn.sharedInstance.signIn(
            withPresenting: topVC,
            hint: nil,
            additionalScopes: ["https://www.googleapis.com/auth/yt-analytics.readonly"]
        ) { signInResult, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = signInResult?.user else {
                let tokenError = NSError(domain: "AuthError", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve user during YouTube connect."])
                completion(.failure(tokenError))
                //print("Error connecting YouTube: User not found in result")
                return
            }
            
            let accessToken = user.accessToken.tokenString
            let refreshToken = user.refreshToken.tokenString
            let serverAuthCode = signInResult?.serverAuthCode ?? ""
            

            
            completion(.success(.init(
                serverAuthCode: serverAuthCode
            )))
        }
    }
}




extension UIApplication {
    @MainActor
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
