////
////  GoogleAuthRemoteDataSourceImpl.swift
////  Shopped-In
////
////  Created by Ayatullah Salah on 11/06/2025.
////
//
//import Foundation
//import GoogleSignIn
//import FirebaseAuth
//import FirebaseFirestore
//import FirebaseCore
//
//class GoogleAuthRemoteDataSourceImpl: GoogleAuthRemoteDataSource {
//    func signInWithGoogle(presentingViewController: UIViewController,
//                          completion: @escaping (Result<UserDTO, Error>) -> Void) {
//        guard let clientID = FirebaseApp.app()?.options.clientID else {
//            completion(.failure(AuthError.noData))
//            return
//        }
//        
//        let config = GIDConfiguration(clientID: clientID)
//        GIDSignIn.sharedInstance.configuration = config
//        
//        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { signInResult, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            
//            guard let user = signInResult?.user,
//                  let idToken = user.idToken?.tokenString else {
//                try? Auth.auth().signOut()
//                completion(.failure(AuthError.noData))
//                return
//            }
//            
//            let accessToken = user.accessToken.tokenString
//            
//            
//            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
//            Auth.auth().signIn(with: credential) { result, error in
//                if let error = error {
//                    completion(.failure(error))
//                    return
//                }
//                
//                guard let firebaseUser = result?.user else {
//                    try? Auth.auth().signOut()
//                    completion(.failure(AuthError.noData))
//                    return
//                }
//                
//                let uid = firebaseUser.uid
//                let db = Firestore.firestore()
//                
//                db.collection("users").document(uid).getDocument { document, error in
//                    if let data = document?.data(),
//                       let existingToken = data["token"] as? String {
//                        completion(.success(UserDTO(firebaseUser: firebaseUser, randomToken: existingToken)))
//                    } else {
//                        let randomToken = String(UUID().uuidString.prefix(16))
//                        let data: [String: Any] = [
//                            "email": firebaseUser.email ,
//                            "firstName": firebaseUser.displayName as Any ,
//                            "token": randomToken
//                        ]
//                        
//                        db.collection("users").document(uid).setData(data, merge: true) { error in
//                            if let error = error {
//                                try? Auth.auth().signOut()
//                                completion(.failure(error))
//                            } else {
//                                completion(.success(UserDTO(firebaseUser: firebaseUser, randomToken: randomToken)))
//                            }
//                        }
//                    }
//                }
//            }
//            
//        }}
//
//    func signOut() {
//        GIDSignIn.sharedInstance.signOut()
//        try? Auth.auth().signOut()
//    }
//}
