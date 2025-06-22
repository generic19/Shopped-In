//
//  AuthViewModel.swift
//  shopify
//
//  Created by Ayatullah Salah on 28/05/2025.
//

import Foundation
import FirebaseAuth
import UIKit

class AuthViewModel: ObservableObject {
    // MARK: - Input
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var phone: String = ""
    
    // MARK: - Output
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var shouldShowErrorAlert = false
    @Published var isGuest: Bool = false
    @Published var isAuthenticated: Bool = false
    
    private let signUpUseCase: SignUpUseCase
    private let signInUseCase: SignInUseCase
    private let getCurrentUserUseCase: GetCurrentUserUseCase
    private let signOutUseCase: SignOutUseCase
    private let signInwithGoogleUseCase: SignInWithGoogleUseCase
    
    init(
        signUpUseCase: SignUpUseCase,
        signInUseCase: SignInUseCase,
        getCurrentUserUseCase: GetCurrentUserUseCase,
        signOutUseCase: SignOutUseCase,
        signInwithGoogleUseCase: SignInWithGoogleUseCase
    ) {
        self.signUpUseCase = signUpUseCase
        self.signInUseCase = signInUseCase
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.signOutUseCase = signOutUseCase
        self.signInwithGoogleUseCase=signInwithGoogleUseCase
        
        $errorMessage
            .map { $0 != nil }
            .removeDuplicates()
            .assign(to: &$shouldShowErrorAlert)
    }
    
    // MARK: - Sign Up
    
    func signUp() {
        validateSignUp()
        if errorMessage != nil { return }
        
        let user = User(email: email, phone: phone, firstName: firstName, lastName: lastName, customerID: nil)
        
        isLoading = true
        
        signUpUseCase.execute(user: user, password: password) { [unowned self] error in
            isLoading = false
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            self.isAuthenticated = true
        }
    }
    
    private func validateSignUp() {
        if !isValidEmail(email) {
            errorMessage = "Invalid email format"
        } else if !isValidPassword(password) {
            errorMessage = "Password must be at least 6 characters long"
        } else if !isValidPhoneNumber(phone) {
            errorMessage = "Invalid phone number"
        } else if firstName.isEmpty {
            errorMessage = "First name is required"
        } else if lastName.isEmpty {
            errorMessage = "Last name is required"
        } else {
            errorMessage = nil
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }
    
    private func isValidPhoneNumber(_ phone: String) -> Bool {
        return phone.count >= 10
    }
    
    // MARK: - Sign In
    
    func signIn() {
        validateSignIn()
        if errorMessage != nil { return }
        
        isLoading = true
        
        signInUseCase.execute(email: email, password: password) { [unowned self] error in
            isLoading = false
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            self.isAuthenticated = true
        }
    }
    
    private func validateSignIn() {
        if !isValidEmail(email) {
            errorMessage = "Invalid email format"
        } else if !isValidPassword(password) {
            errorMessage = "Password must be at least 6 characters long"
        } else {
            errorMessage = nil
        }
    }
    
    // MARK: - Continue as Guest
    
    func continueAsGuest() {
        isGuest = true
        isAuthenticated = false 
    }
    
    // MARK: - Sign Out
    
    func signOut() {
        isLoading = true
        
        signOutUseCase.execute { [unowned self] in
            self.isLoading = false
            self.isAuthenticated = false
        }
    }
    // MARK: - Sign In with Google
    func signInWithGoogle(presentingViewController: UIViewController) {
        isLoading = true

        signInwithGoogleUseCase.execute(presentingViewController: presentingViewController) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.isAuthenticated = true
                }
            }
        }
    }

    
}
