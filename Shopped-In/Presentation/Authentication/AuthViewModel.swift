//
//  AuthViewModel.swift
//  shopify
//
//  Created by Ayatullah Salah on 28/05/2025.
//

import Foundation
import FirebaseAuth

class AuthViewModel: ObservableObject {
    // MARK: - Input
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var phone: String = ""

    // MARK: - Output
    
    @Published var errorMessage: String = ""
    @Published var accessToken: String? = nil
    @Published var isGuest: Bool = false
    @Published var isAuthenticated: Bool = false

    private let signUpUseCase: SignUpUseCase
    private let signInUseCase: SignInUseCase

    init(signUpUseCase: SignUpUseCase, signInUseCase: SignInUseCase) {
        self.signUpUseCase = signUpUseCase
        self.signInUseCase = signInUseCase
    }

    // MARK: - Sign Up
    
    func signUp() {
        errorMessage = ""

        guard isValidEmail(email) else {
            errorMessage = "Invalid email format"
            return
        }
        guard isValidPassword(password) else {
            errorMessage = "Password must be at least 6 characters long"
            return
        }
        guard isValidPhoneNumber(phone) else {
            errorMessage = "Invalid phone number"
            return
        }
        guard !firstName.isEmpty else {
            errorMessage = "First name is required"
            return
        }
        guard !lastName.isEmpty else {
            errorMessage = "Last name is required"
            return
        }

        
        let user = User(id: UUID().uuidString, email: email, phone: phone, firstName: firstName, lastName: lastName)

        signUpUseCase.execute(user: user, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.isAuthenticated = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    
    // MARK: - Sign In
    
    func signIn() {
        errorMessage = ""
        isGuest = false

        guard isValidEmail(email) else {
            errorMessage = "Invalid email format"
            return
        }
        guard isValidPassword(password) else {
            errorMessage = "Password must be at least 6 characters long"
            return
        }

        signInUseCase.execute(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    self?.accessToken = token
                    self?.isAuthenticated = true
                    UserDefaults.standard.set(token, forKey: UserDefaultsKeys.customerAccessToken)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    // MARK: - Continue as Guest
    
    func continueAsGuest() {
        isGuest = true
        isAuthenticated = false
        accessToken = nil
    }

    // MARK: - Sign Out
    
    func signOut() {
        accessToken = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.customerAccessToken)
    }

    // MARK: - Validation
    
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
}

    

    


