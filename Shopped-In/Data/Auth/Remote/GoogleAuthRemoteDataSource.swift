//
//  GoogleAuthRemoteDataSource.swift
//  Shopped-In
//
//  Created by Ayatullah Salah on 11/06/2025.
//

import Foundation
import GoogleSignIn
protocol GoogleAuthRemoteDataSource {
    func signInWithGoogle(presentingViewController: UIViewController,completion: @escaping (Result<UserDTO, Error>) -> Void)
    func signOut()
}
