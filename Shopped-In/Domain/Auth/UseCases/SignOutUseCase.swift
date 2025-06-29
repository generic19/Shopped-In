//
//  SignOutUseCase.swift
//  Shopped-In
//
//  Created by Ayatullah Salah on 08/06/2025.
//

import Foundation

protocol SignOutUseCase {
    func execute(completion: @escaping () -> Void)
}

class SignOutUseCaseImpl: SignOutUseCase {
    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func execute(completion: @escaping () -> Void) {
        authRepository.signOut(completion: completion)
    }
}
