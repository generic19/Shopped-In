import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class AuthRepositoryImpl: AuthRepository {
   
    
    private let tokenRepository: TokenRepo
    private let apiSource:APIAuthRemoteDataSource
    private let firebaseSource:FireBaseAuthRemoteDataSource
    private let googleSource: GoogleAuthRemoteDataSource

    init(tokenRepository: TokenRepo,
         apiSource: APIAuthRemoteDataSource,
         firebaseSource: FireBaseAuthRemoteDataSource,
         googleSource: GoogleAuthRemoteDataSource) {
        self.tokenRepository = tokenRepository
        self.apiSource = apiSource
        self.firebaseSource = firebaseSource
        self.googleSource = googleSource
    }
    func signInWithGoogle(presentingViewController: UIViewController, completion: @escaping (Error?) -> Void) {
        googleSource.signInWithGoogle(presentingViewController: presentingViewController) { [unowned self] result in
            switch result {
            case .success(let userDTO):
                guard let email = userDTO.firebaseUser.email else {
                    completion(AuthError.noData)
                    return
                }

                self.apiSource.signInCustomer(email: email, password: userDTO.randomToken) { result in
                    switch result {
                    case .success(let accessToken):
                        self.tokenRepository.saveToken(accessToken)
                        completion(nil)

                    case .failure:
                        // Ask for phone number
                        let alert = UIAlertController(
                            title: "Phone Number",
                            message: "Please enter your phone number",
                            preferredStyle: .alert
                        )
                        alert.addTextField { textField in
                            textField.placeholder = "Phone Number"
                            textField.keyboardType = .phonePad
                        }

                        let submitAction = UIAlertAction(title: "Submit", style: .default) { _ in
                            let phone = alert.textFields?.first?.text ?? ""
                            let name = userDTO.firebaseUser.displayName ?? ""
                            let nameComponents = name.split(separator: " ")
                            let firstName = nameComponents.first.map(String.init) ?? "User"
                            let lastName = nameComponents.dropFirst().joined(separator: " ")

                            let user = User(
                                email: email,
                                phone: phone,
                                firstName: firstName,
                                lastName: lastName,
                                customerID: nil
                            )

                            self.apiSource.createCustomer(user: user, password: userDTO.randomToken) { error in
                                if let error = error {
                                    self.googleSource.signOut()
                                    completion(error)
                                } else {
                                    self.tokenRepository.saveToken(userDTO.randomToken)
                                    completion(nil)
                                }
                            }
                        }

                        alert.addAction(submitAction)

                        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                            self.googleSource.signOut()
                            let cancelError = NSError(
                                domain: "Auth",
                                code: 999,
                                userInfo: [NSLocalizedDescriptionKey: "User cancelled phone input"]
                            )
                            completion(cancelError)
                        }

                        alert.addAction(cancelAction)
                        presentingViewController.present(alert, animated: true)
                    }
                }

            case .failure(let error):
                completion(error)
            }
        }
    }


    func signIn(email: String, password: String, completion: @escaping (Error?) -> Void){
        firebaseSource.signIn(email: email, password: password) { [unowned self] result in
            switch result {
                case .success(let userDTO):
                    self.apiSource.signInCustomer(email: email, password: userDTO.randomToken) { result in
                        switch result {
                            case .success(let accessToken):
                                self.tokenRepository.saveToken(accessToken)
                            print("save token:\(self.tokenRepository.loadToken())")
                                completion(nil)
                                
                            case .failure(let error):
                                self.firebaseSource.signOut()
                                completion(error)
                        }
                    }
                    
                case .failure(let error):
                    completion(error)
            }
        }
    }
    
    func signUp(user: User, password: String, completion: @escaping (Error?) -> Void) {
        firebaseSource.signUp(user: user, password: password) { [unowned self] result in
            switch result {
                case .success(let userDTO):
                    self.apiSource.createCustomer(user: user, password: userDTO.randomToken) { error in
                        if let error = error {
                            self.firebaseSource.rollbackSignUp {
                                completion(error)
                            }
                            return
                        }
                        
                        self.apiSource.signInCustomer(email: user.email, password: userDTO.randomToken) { result in
                            switch result {
                                case .success(let accessToken):
                                    self.tokenRepository.saveToken(accessToken)
                                    completion(nil)
                                    
                                case .failure(let error):
                                    self.firebaseSource.signOut()
                                    completion(error)
                            }
                        }
                    }
                    
                case .failure(let error):
                    completion(error)
            }
        }
    }
    
    func signOut(completion: @escaping () -> Void) {
        guard let token = tokenRepository.loadToken() else {
            firebaseSource.signOut()
            completion()
            return
        }
        
        apiSource.signOutCustomer(token: token) {
            self.firebaseSource.signOut()
            self.tokenRepository.deleteToken()
            completion()
        }
    }
    
    func getCurrentUser() -> User? {
        guard let user = firebaseSource.getCurrentUser() else { return nil }
        return User.from(firebaseUser: user, customer: nil)
    }
}
