import Foundation
import Combine
import UIKit

class AuthRepositoryImpl: AuthRepository {
    private let tokenRepository: TokenRepo
    private let apiSource: APIAuthRemoteDataSource
    private let firebaseSource: FireBaseAuthRemoteDataSource
    
    private let currentUserSubject = CurrentValueSubject<User?, Never>(nil)
    var currentUser: AnyPublisher<User?, Never> { currentUserSubject.eraseToAnyPublisher() }
    
    init(
        tokenRepository: TokenRepo,
        apiSource: APIAuthRemoteDataSource,
        firebaseSource: FireBaseAuthRemoteDataSource,
    ) {
        self.tokenRepository = tokenRepository
        self.apiSource = apiSource
        self.firebaseSource = firebaseSource
    }
    
    func signInWithGoogle(
        presentingViewController: UIViewController,
        completion: @escaping (Error?) -> Void
    ) {
        firebaseSource.signInWithGoogle(
            presentingViewController: presentingViewController
        ) { [weak self] result in
            switch result {
                case .success(let userDTO):
                    print("sucess sign in with google")
                    guard let email = userDTO.firebaseUser.email else {
                        completion(AuthError.noData)
                        return
                    }
                    
                    self?.apiSource.signInCustomer(
                        email: email,
                        password: userDTO.randomToken
                    ) { result in
                        switch result {
                            case .success(let accessToken):
                                print("success sign in ")
                                self?.tokenRepository.saveToken(accessToken)
                                print(accessToken)
                                
                                print("acess token 2 \(self?.tokenRepository.loadToken())")
                                completion(nil)
                                
                            case .failure:
                                print("failure sign in")
                                let name = userDTO.firebaseUser.displayName ?? ""
                                let nameComponents = name.split(separator: " ")
                                let firstName =
                                nameComponents.first.map(String.init) ?? "User"
                                let lastName = nameComponents.dropFirst().joined(
                                    separator: " "
                                )
                                
                                let user = User(
                                    email: email,
                                    phone: nil,
                                    firstName: firstName,
                                    lastName: lastName,
                                    customerID: nil
                                )
                                
                                self?.apiSource.createCustomer(
                                    user: user,
                                    password: userDTO.randomToken
                                ) { error in
                                    if let error = error {
                                        self?.firebaseSource.signOut()
                                        completion(error)
                                        
                                        return
                                    }
                                    self?.apiSource.signInCustomer(
                                        email: user.email,
                                        password: userDTO.randomToken
                                    ) { result in
                                        switch result {
                                            case .success(let accessToken):
                                                self?.tokenRepository.saveToken(accessToken)
                                                completion(nil)
                                                
                                            case .failure(let error):
                                                self?.firebaseSource.signOut()
                                                completion(error)
                                        }
                                    }
                                    
                                }
                        }
                    }
                    
                case .failure(let error):
                    completion(error)
            }
        }
    }
    
    func signIn(
        email: String,
        password: String,
        completion: @escaping (Error?) -> Void
    ) {
        firebaseSource.signIn(email: email, password: password) { [weak self] result in
            guard let self else { return }
            
            switch result {
                case .success(let userDTO):
                    signInCustomer(userDTO: userDTO, completion: completion)
                    
                case .failure(let error):
                    completion(error)
            }
        }
    }
    
    private func signInCustomer(userDTO: UserDTO, completion: @escaping (Error?) -> Void) {
        self.apiSource.signInCustomer(
            email: userDTO.firebaseUser.email!,
            password: userDTO.randomToken
        ) { result in
            switch result {
                case .success(let accessToken):
                    self.apiSource.getCustomer(token: accessToken) { result in
                        switch result {
                            case .success(var user):
                                self.tokenRepository.saveToken(accessToken)
                                
                                user.isVerified = userDTO.firebaseUser.isEmailVerified
                                self.currentUserSubject.value = user
                                
                                completion(nil)
                                
                            case .failure(let error):
                                self.apiSource.signOutCustomer(token: accessToken) {
                                    self.firebaseSource.signOut()
                                    self.currentUserSubject.value = nil
                                    completion(error)
                                }
                        }
                    }
                    
                case .failure(let error):
                    self.firebaseSource.signOut()
                    self.currentUserSubject.value = nil
                    completion(error)
            }
        }
    }
    
    func signUp(
        user: User,
        password: String,
        completion: @escaping (Error?) -> Void
    ) {
        firebaseSource.signUp(user: user, password: password) { [weak self] result in
            guard let self else { return }
            
            switch result {
                case .success(let userDTO):
                    self.apiSource.createCustomer(
                        user: user,
                        password: userDTO.randomToken
                    ) { error in
                        if let error {
                            self.firebaseSource.rollbackSignUp {
                                completion(error)
                            }
                            return
                        }
                        
                        self.apiSource.signInCustomer(
                            email: user.email,
                            password: userDTO.randomToken
                        ) { result in
                            switch result {
                                case .success(let accessToken):
                                    self.apiSource.getCustomer(token: accessToken) { result in
                                        switch result {
                                            case .success(var user):
                                                self.tokenRepository.saveToken(accessToken)
                                                
                                                user.isVerified = userDTO.firebaseUser.isEmailVerified
                                                
                                                if !user.isVerified {
                                                    self.firebaseSource.sendEmailVerification()
                                                }
                                                
                                                self.currentUserSubject.value = user
                                                completion(nil)
                                                
                                            case .failure(let error):
                                                self.apiSource.signOutCustomer(token: accessToken) {
                                                    self.firebaseSource.signOut()
                                                    self.currentUserSubject.value = nil
                                                    completion(error)
                                                }
                                        }
                                    }
                                    
                                case .failure(let error):
                                    self.firebaseSource.signOut()
                                    self.currentUserSubject.value = nil
                                    completion(error)
                            }
                        }
                    }
                    
                case .failure(let error):
                    self.currentUserSubject.value = nil
                    completion(error)
            }
        }
    }
    
    func signOut(completion: @escaping () -> Void) {
        guard let token = tokenRepository.loadToken() else {
            firebaseSource.signOut()
            self.currentUserSubject.value = nil
            completion()
            return
        }
        
        apiSource.signOutCustomer(token: token) {
            self.firebaseSource.signOut()
            self.tokenRepository.deleteToken()
            self.currentUserSubject.value = nil
            completion()
        }
    }
    
    func automaticSignIn(completion: @escaping (Bool) -> Void) {
        firebaseSource.getUserDTO { result in
            switch result {
                case .success(let dto):
                    guard let email = dto.firebaseUser.email else {
                        if let token = self.tokenRepository.loadToken() {
                            self.apiSource.signOutCustomer(token: token) {
                                self.tokenRepository.deleteToken()
                                completion(false)
                            }
                        } else {
                            completion(false)
                        }
                        return
                    }
                    
                    self.apiSource.signInCustomer(email: email, password: dto.randomToken) { result in
                        switch result {
                            case .success(let accessToken):
                                self.apiSource.getCustomer(token: accessToken) { result in
                                    switch result {
                                        case .success(var user):
                                            self.tokenRepository.saveToken(accessToken)
                                            
                                            user.isVerified = dto.firebaseUser.isEmailVerified
                                            self.currentUserSubject.value = user
                                            
                                            completion(true)
                                            
                                        case .failure(_):
                                            if let token = self.tokenRepository.loadToken() {
                                                self.firebaseSource.signOut()
                                                
                                                self.apiSource.signOutCustomer(token: token) {
                                                    self.tokenRepository.deleteToken()
                                                    completion(false)
                                                }
                                            } else {
                                                completion(false)
                                            }
                                    }
                                }
                                
                            case .failure(_):
                                self.firebaseSource.signOut()
                                
                                if let token = self.tokenRepository.loadToken() {
                                    self.apiSource.signOutCustomer(token: token) {
                                        self.tokenRepository.deleteToken()
                                        completion(false)
                                    }
                                } else {
                                    completion(false)
                                }
                        }
                    }
                    
                case .failure(_):
                    if let token = self.tokenRepository.loadToken() {
                        self.apiSource.signOutCustomer(token: token) {
                            self.tokenRepository.deleteToken()
                            completion(false)
                        }
                    } else {
                        completion(false)
                    }
            }
        }
    }
    
    func resendVerificationEmail() {
        firebaseSource.sendEmailVerification()
    }
    
    func reloadUser() {
        let oldUser = self.currentUserSubject.value
        
        firebaseSource.reloadUser { dto in
            guard let dto else {
                self.currentUserSubject.value = nil
                return
            }
            
            let newEmail = dto.firebaseUser.email
            let isVerified = dto.firebaseUser.isEmailVerified
            
            if oldUser?.email != newEmail ||
                oldUser?.isVerified != isVerified || true
            {
                self.signInCustomer(userDTO: dto) { _ in }
            }
        }
    }
}
