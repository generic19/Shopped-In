//
//  SignInWithGoogleUseCase.swift
//  Shopped-In
//
//  Created by Ayatullah Salah on 11/06/2025.
//

import UIKit

class SignInWithGoogleUseCase {
    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func execute(presentingViewController: UIViewController, completion: @escaping (Error?) -> Void) {
        authRepository.signInWithGoogle(presentingViewController: presentingViewController, completion: completion)
    }
}
