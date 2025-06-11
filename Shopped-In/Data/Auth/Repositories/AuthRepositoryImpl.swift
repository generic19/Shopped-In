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
                    case .failure(let error):
                        self.googleSource.signOut()
                        completion(error)
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
