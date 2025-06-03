import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class AuthRepositoryImpl: AuthRepository {
    private let tokenRepository: TokenRepo=StubTokenRepo()
    
    
    func signIn(email: String, password: String, completion:@escaping (Result<String, Error>) -> Void){
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                return completion(.failure(error))
            }

            guard let firebaseUser = result?.user else {
                return completion(.failure(NSError(domain: "Firebase", code: 1)))
            }

            let uid = firebaseUser.uid
            let db = Firestore.firestore()

            db.collection("users").document(uid).getDocument { document, error in
                if let data = document?.data(),
                   let shopifyToken = data["token"] as? String {
                    
                    ApiClient.shared.signInCustomer(email: email, password: shopifyToken) { accessToken in
                        if let token = accessToken {
                            self.tokenRepository.saveToken(token)
                            
                            completion(.success(token))
                        } else {
                            completion(.failure(NSError(domain: "Shopify", code: 2)))
                        }
                    }
                } else {
                    completion(.failure(NSError(domain: "Firestore", code: 3)))
                }
            }
        }
    }
    
    func signUp(user: User, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let userDTO = AuthMapper.toDTO(from: user)
        let token = String(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(16))

        Auth.auth().createUser(withEmail: userDTO.email, password: password) { result, error in
            if let error = error {
                return completion(.failure(error))
            }

            guard let firebaseUser = result?.user else {
                return completion(.failure(NSError(domain: "Firebase", code: 0)))
            }

            firebaseUser.sendEmailVerification()

            let db = Firestore.firestore()
            db.collection("users").document(firebaseUser.uid).setData([
                "email": userDTO.email,
                "firstName": userDTO.firstName,
                "lastName": userDTO.lastName,
                "phone": userDTO.phone,
                "token": token
            ]) { err in
                if let err = err {
                    return completion(.failure(err))
                }

                ApiClient.shared.createCustomer(
                    email: userDTO.email,
                    password: token,
                    phone: userDTO.phone,
                    firstName: userDTO.firstName,
                    lastName: userDTO.lastName
                )
                ApiClient.shared.signInCustomer(email: userDTO.email, password: token, completion: { token in
                    if let token = token {
                        self.tokenRepository.saveToken(token)
                        completion(.success(()))
                    }else {
                        completion(.failure(NSError(domain: "Firebase", code: 0)))
                    }
                })

             
            }
        }
    }

    

    
    func signOut() {
        if let token = tokenRepository.loadToken(){
            ApiClient.shared.signOutCustomer(token: token){
                self.tokenRepository.deleteToken()
            }
        }else{
            return
        }
        
    }
    
    
    
}

