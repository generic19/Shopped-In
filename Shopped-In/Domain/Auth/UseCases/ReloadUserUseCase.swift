//
//  ReloadUserUseCase.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 20/06/2025.
//

protocol ReloadUserUseCase {
    func execute()
}

class ReloadUserUseCaseImpl: ReloadUserUseCase {
    private let repo: AuthRepository
    
    init(repo: AuthRepository) {
        self.repo = repo
    }
    
    func execute() {
        repo.reloadUser()
    }
}
