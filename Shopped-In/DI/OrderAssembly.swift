//
//  OrderAssembly.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 20/06/2025.
//

import Swinject

class OrderAssembly: Assembly {
    func assemble(container: Swinject.Container) {
        container.register(OrderRemoteDataSource.self) { r in
            OrderRemoteDataSourceImpl(
                service: r.resolve(AlamofireAPIService.self)!
            )
        }
        .inObjectScope(.container)
        
        container.register(OrderRepository.self) { r in
            OrderRepositoryImpl(
                remote: r.resolve(OrderRemoteDataSource.self)!
            )
        }.inObjectScope(.container)
    }
}
