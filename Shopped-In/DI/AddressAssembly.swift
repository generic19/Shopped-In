//
//  AddressAssembly.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 20/06/2025.
//
import Swinject

class AddressAssembly: Assembly {
    func assemble(container: Container) {
        container.register(AddressRemoteDataSource.self) { r in
            AddressRemoteDataSourceImpl(service: r.resolve(BuyAPIService.self)!)
        }.inObjectScope(.container)
        
        container.register(AddressRepository.self) { r in
            AddressRepositoryImpl(remote: r.resolve(AddressRemoteDataSource.self)!)
        }.inObjectScope(.container)
    }
}
