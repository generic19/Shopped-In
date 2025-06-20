//
//  AuthAssembly.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 20/06/2025.
//

import Swinject

class AuthAssembly: Assembly {
    func assemble(container: Container) {
        container.register(APIAuthRemoteDataSource.self) { r in
            APIAuthRemoteDataSourceImpl(
                service: r.resolve(BuyAPIService.self)!
            )
        }.inObjectScope(.container)
        
        container.register(FireBaseAuthRemoteDataSource.self) { _ in
            FireBaseAuthRemoteDataSourceImpl()
        }.inObjectScope(.container)
        
        container.register(AuthRepository.self) { r in
            AuthRepositoryImpl(
                tokenRepository: r.resolve(TokenRepo.self)!,
                apiSource: r.resolve(APIAuthRemoteDataSource.self)!,
                firebaseSource: r.resolve(FireBaseAuthRemoteDataSource.self)!
            )
        }.inObjectScope(.container)
    }
}
