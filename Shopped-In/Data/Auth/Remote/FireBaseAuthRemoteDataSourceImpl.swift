//
//  FireBaseAuthRemoteDataSourceImpl.swift
//  Shopped-In
//
//  Created by Ayatullah Salah on 08/06/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import GoogleSignIn


class FireBaseAuthRemoteDataSourceImpl : FireBaseAuthRemoteDataSource {
    func signInWithGoogle(presentingViewController: UIViewController, completion: @escaping (Result<UserDTO, any Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(AuthError.noData))
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { signInResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = signInResult?.user,
                  let idToken = user.idToken?.tokenString else {
                try? Auth.auth().signOut()
                completion(.failure(AuthError.noData))
                return
            }
            
            let accessToken = user.accessToken.tokenString
            
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let firebaseUser = result?.user else {
                    try? Auth.auth().signOut()
                    completion(.failure(AuthError.noData))
                    return
                }
                
                let uid = firebaseUser.uid
                let db = Firestore.firestore()
                
                db.collection("users").document(uid).getDocument { document, error in
                    if let data = document?.data(),
                       let existingToken = data["token"] as? String {
                        completion(.success(UserDTO(firebaseUser: firebaseUser, randomToken: existingToken)))
                    } else {
                        let randomToken = String(UUID().uuidString.prefix(16))
                        let data: [String: Any] = [
                            "email": firebaseUser.email ,
                            "firstName": firebaseUser.displayName as Any ,
                            "token": randomToken
                        ]
                        
                        db.collection("users").document(uid).setData(data, merge: true) { error in
                            if let error = error {
                                try? Auth.auth().signOut()
                                completion(.failure(error))
                            } else {
                                completion(.success(UserDTO(firebaseUser: firebaseUser, randomToken: randomToken)))
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    func getCurrentUser() -> FirebaseAuth.User? {
        return Auth.auth().currentUser
    }
    
    func getUserDTO(completion: @escaping (Result<UserDTO, Error>) -> Void) {
        let auth = Auth.auth()
        
        guard let currentUser = auth.currentUser else {
            completion(.failure(AuthError.noData))
            return
        }
        
        currentUser.reload { error in
            if let error {
                completion(.failure(error))
                return
            }
            
            guard let user = auth.currentUser else {
                completion(.failure(AuthError.noData))
                return
            }
            
            let firestore = Firestore.firestore()
            firestore.collection("users").document(user.uid).getDocument { document, error in
                if let error {
                    completion(.failure(error))
                    return
                }
                
                guard let randomToken = document?.data()?["token"] as? String else {
                    completion(.failure(AuthError.noData))
                    return
                }
                
                let userDTO = UserDTO(firebaseUser: user, randomToken: randomToken)
                completion(.success(userDTO))
            }
        }
    }
    
    func signIn(email: String, password: String, completion:@escaping (Result<UserDTO, Error>) -> Void){
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error: Error = error {
                completion(.failure(error))
                return
            }
            
            guard let firebaseUser = result?.user else {
                completion(.failure(AuthError.noData))
                return
            }
            
            let uid = firebaseUser.uid
            let db = Firestore.firestore()
            
            db.collection("users").document(uid).getDocument { document, error in
                if let data = document?.data(),
                    let randomToken = data["token"] as? String
                {
                    completion(.success(UserDTO(firebaseUser: firebaseUser, randomToken: randomToken)))
                } else {
                    try? Auth.auth().signOut()
                    return completion(.failure(AuthError.noData))
                }
            }
        }
    }
    
    func signUp(user: User, password: String, completion: @escaping (Result<UserDTO, Error>) -> Void){
        let randomToken = String(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(16))
        
        Auth.auth().createUser(withEmail: user.email, password: password) { result, error in
            if let error = error {
                return completion(.failure(error))
            }
            
            guard let firebaseUser = result?.user else {
                try? Auth.auth().signOut()
                completion(.failure(AuthError.noData))
                return
            }
            
            let db = Firestore.firestore()
            
            let data: [String: Any] = [
                "email": user.email,
                "firstName": user.firstName as Any,
                "lastName": user.lastName as Any,
                "phone": user.phone as Any,
                "token": randomToken
            ]
            
            db.collection("users").document(firebaseUser.uid).setData(data) { error in
                if let error = error {
                    try? Auth.auth().signOut()
                    completion(.failure(error))
                    return
                } else {
                    let userDTO = UserDTO(firebaseUser: firebaseUser, randomToken: randomToken)
                    completion(.success(userDTO))
                    return
                }
            }
        }
    }
    
    func sendEmailVerification() {
        Auth.auth().currentUser?.sendEmailVerification()
    }
    
    func rollbackSignUp(completion: @escaping () -> Void) {
        Auth.auth().currentUser?.delete { _ in
            completion()
        }
    }
    
    func signOut() {
        try? Auth.auth().signOut()
    }
}
