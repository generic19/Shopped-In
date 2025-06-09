import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class AuthRepositoryImpl: AuthRepository {
  
    
    
    private let tokenRepository: TokenRepo
    private let apiSource:APIAuthRemoteDataSource
    private let firebaseSource:FireBaseAuthRemoteDataSource
    init(tokenRepository: TokenRepo, apiSource: APIAuthRemoteDataSource, firebaseSource: FireBaseAuthRemoteDataSource) {
        self.tokenRepository = tokenRepository
        self.apiSource = apiSource
        self.firebaseSource = firebaseSource
    }
    
    
    func signIn(email: String, password: String, completion:@escaping (Result<Void, Error>) -> Void){
        firebaseSource.signIn(email:email, password:password){result in
            switch result {
            case .success(let userDTO):
                
                self.apiSource.signInCustomer(email: email, password:userDTO.randomToken) { result in
                    switch result {
                    case .success(let accessToken):
                        self.tokenRepository.saveToken(accessToken)
                        
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func signUp(user: User, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        firebaseSource.signUp(user: user, password: password) { result
            in
            switch result{
            case .success(let userDTO):
                self.apiSource.createCustomer(email: user.email, password:userDTO.randomToken, phone:user.phone , firstName: user.firstName, lastName: user.lastName) { result in
                    switch result {
                    case .success(let customerId):
                        self.apiSource.signInCustomer(email: user.email, password:userDTO.randomToken) { result in
                            switch result {
                            case .success(let accessToken):
                                self.tokenRepository.saveToken(accessToken)
                            case .failure(let error):
                                completion(.failure(error))
                            }
                            
                            
                        }
                        
                    case .failure(let error):
                        completion(.failure(error))
                    }
                    
                    
                    
                }
            case .failure(let error):
                completion(.failure(error))
                
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
    
    func continueAsGuest() {
        
    }
    
    func isVerified()-> Bool {
        return firebaseSource.isVerified()
    }
    
    func getCurrentUser() -> FirebaseAuth.User?{
       return  firebaseSource.getCurrentUser()
        }
    
   
    
}

