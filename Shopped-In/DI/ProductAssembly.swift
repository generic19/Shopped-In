//
//  ProductAssembly.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 20/06/2025.
//

import Swinject

class ProductAssembly: Assembly {
    func assemble(container: Swinject.Container) {
        container.register(ProductRemoteDataSource.self) { r in
            ProductRemoteDataSourceImpl(
                service: r.resolve(BuyAPIService.self)!
            )
        }.inObjectScope(.container)
        
        container.register(ProductRepository.self) { r in
            ProductRepositoryImpl(
                remote: r.resolve(ProductRemoteDataSource.self)!
            )
        }.inObjectScope(.container)
    }
}
