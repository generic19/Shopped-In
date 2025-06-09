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
    func isVerified() -> Bool {
      return Auth.auth().currentUser?.isEmailVerified ?? false
            }
    
    func getCurrentUser()->FirebaseAuth.User? {
        return Auth.auth().currentUser

    }
    
    func signIn(email: String, password: String, completion:@escaping (Result<UserDTO, Error>) -> Void){
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error: Error = error {
                return completion(.failure(error))
            }

            guard let firebaseUser = result?.user else {
                return completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "No user returned"])))
            }

            let uid = firebaseUser.uid
            let db = Firestore.firestore()

            db.collection("users").document(uid).getDocument { document, error in
                if let data = document?.data(),
                   let randomToken = data["token"] as? String {
                    completion(.success(UserDTO(firebaseUser: firebaseUser, randomToken: randomToken)))
                } else {
                    return completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "could not read user data"])))

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
                return completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "No user returned"])))

            }

            firebaseUser.sendEmailVerification()

            let db = Firestore.firestore()
            db.collection("users").document(firebaseUser.uid).setData([
                "email": user.email,
                "firstName": user.firstName,
                "lastName": user.lastName,
                "phone": user.phone,
                "token": randomToken
            ]) { err in
                if let err = err {
                    return completion(.failure(err))
                    
                }
                else {
                    let userDTO = UserDTO(firebaseUser: firebaseUser, randomToken: randomToken)
                    return completion(.success(userDTO))
                }
                

            }
        }
    }
    
    func signOut(){
       try? Auth.auth().signOut()
    }

}
