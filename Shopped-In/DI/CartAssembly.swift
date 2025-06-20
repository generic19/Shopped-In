//
//  CartAssembly.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 20/06/2025.
//

import Swinject

class CartAssembly: Assembly {
    func assemble(container: Container) {
        container.register(CartRemoteDataSource.self) { r in
            CartRemoteDataSourceImpl(
                service: r.resolve(BuyAPIService.self)!
            )
        }.inObjectScope(.container)
        
        container.register(CartSessionLocalDataSource.self) { r in
            CartSessionLocalDataSourceImpl()
        }
        .inObjectScope(.container)
        
        container.register(CartRepository.self) { r in
            CartRepositoryImpl(
                remote: r.resolve(CartRemoteDataSource.self)!,
                local: r.resolve(CartSessionLocalDataSource.self)!,
            )
        }.inObjectScope(.container)
    }
}
