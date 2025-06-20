//
//  GetCustomerAccessTokenUseCase.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 13/06/2025.
//

protocol GetCustomerAccessTokenUseCase {
    func execute() -> String?
}

class GetCustomerAccessTokenUseCaseImpl: GetCustomerAccessTokenUseCase {
    private let repository: TokenRepo

    init(repository: TokenRepo) {
        self.repository = repository
    }

    func execute() -> String? {
        return repository.loadToken()
    }
}
