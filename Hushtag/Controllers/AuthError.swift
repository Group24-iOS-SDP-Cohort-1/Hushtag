//
//  AuthError.swift
//  Hushtag
//
//  Created by SDC-USER on 24/01/26.
//

import Foundation

enum AuthError: LocalizedError {
    case emptyFields
    case invalidEmail
    case weakPassword
    case passwordsDoNotMatch
    case invalidCredentials
    case sessionMissing
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .emptyFields:
            return "All fields are required."
        case .invalidEmail:
            return "Please enter a valid email address."
        case .weakPassword:
            return """
            Password must be at least 8 characters long and include:
            • Uppercase letter
            • Lowercase letter
            • Number
            • Special character
            """
        case .passwordsDoNotMatch:
            return "Password and Confirm Password do not match."
        case .invalidCredentials:
            return "Invalid email or password."
        case .sessionMissing:
            return "Account created. Please verify your email before logging in."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}
