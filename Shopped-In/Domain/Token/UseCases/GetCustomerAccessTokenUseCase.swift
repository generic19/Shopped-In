//
//  GetCustomerAccessTokenUseCase.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 13/06/2025.
//

class GetCustomerAccessTokenUseCase {
    let repository: TokenRepo
    
    init(repository: TokenRepo) {
        self.repository = repository
    }
    
    func execute() -> String? {
        return repository.loadToken()
    }
}
