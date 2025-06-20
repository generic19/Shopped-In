//
//  TokenAssembly.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 20/06/2025.
//

import Swinject

class TokenAssembly: Assembly {
    func assemble(container: Swinject.Container) {
        container.register(KeychainHelper.self) { _ in
            KeychainHelper()
        }.inObjectScope(.container)
        
        container.register(TokenRepo.self) { r in
            TokenRepoImpl()
        }.inObjectScope(.container)
        
        container.register(GetCustomerAccessTokenUseCase.self) { r in
            GetCustomerAccessTokenUseCaseImpl(repository: r.resolve(TokenRepo.self)!)
        }.inObjectScope(.graph)
    }
}
