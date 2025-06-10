//
//  FireBaseAuthRemoteDataSourceImpl.swift
//  Shopped-In
//
//  Created by Ayatullah Salah on 08/06/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore


class FireBaseAuthRemoteDataSourceImpl : FireBaseAuthRemoteDataSource {
    func getCurrentUser() -> FirebaseAuth.User? {
        return Auth.auth().currentUser
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
            
            firebaseUser.sendEmailVerification()
            
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
    
    func rollbackSignUp(completion: @escaping () -> Void) {
        Auth.auth().currentUser?.delete { _ in
            completion()
        }
    }
    
    func signOut() {
        try? Auth.auth().signOut()
    }
}
