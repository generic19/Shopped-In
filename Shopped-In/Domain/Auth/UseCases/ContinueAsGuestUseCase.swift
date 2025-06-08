//
//  Untitled.swift
//  Shopped-In
//
//  Created by Ayatullah Salah on 08/06/2025.
//

class ContinueAsGuestUseCase {
    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func execute() {
        authRepository.continueAsGuest()
    }
}

