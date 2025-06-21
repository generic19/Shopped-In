//
//  ResendVerificationEmailUseCase.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 20/06/2025.
//

protocol ResendVerificationEmailUseCase {
    func execute()
}

class ResendVerificationEmailUseCaseImpl: ResendVerificationEmailUseCase {
    private let repo: AuthRepository
    
    init(repo: AuthRepository) {
        self.repo = repo
    }
    
    func execute() {
        repo.resendVerificationEmail()
    }
}
