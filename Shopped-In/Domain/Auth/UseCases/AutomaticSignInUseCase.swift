//
//  AutomaticSignInUseCase.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 19/06/2025.
//

class AutomaticSignInUseCase {
    let authRepo: AuthRepository
    
    init(authRepo: AuthRepository) {
        self.authRepo = authRepo
    }
    
    func execute(completion: @escaping (Bool) -> Void) {
        authRepo.automaticSignIn(completion: completion)
    }
}
