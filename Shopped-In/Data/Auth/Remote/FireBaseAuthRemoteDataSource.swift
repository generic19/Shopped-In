//
//  FireBaseAuthRemoteDataSource.swift
//  Shopped-In
//
//  Created by Ayatullah Salah on 08/06/2025.
//
import FirebaseAuth
import UIKit
protocol FireBaseAuthRemoteDataSource {
    func signIn(email: String, password: String, completion:@escaping (Result<UserDTO, Error>) -> Void)
    func signUp(user: User, password: String, completion: @escaping (Result<UserDTO, Error>) -> Void)
    func rollbackSignUp(completion: @escaping () -> Void)
    func signOut()
    func signInWithGoogle(presentingViewController: UIViewController,completion: @escaping (Result<UserDTO, Error>) -> Void)
    func sendEmailVerification()
    func getCurrentUser() -> FirebaseAuth.User?
    func getUserDTO(completion: @escaping (Result<UserDTO, Error>) -> Void)
}
