//
//  BrandAssembly.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 20/06/2025.
//

import Swinject

class BrandAssembly: Assembly {
    func assemble(container: Container) {
        container.register(BrandRemoteDataSource.self) { r in
            BrandRemoteDataSourceImpl(
                service: r.resolve(BuyAPIService.self)!
            )
        }.inObjectScope(.container)
        
        container.register(BrandRepository.self) { r in
            BrandRepositoryImpl(
                remote: r.resolve(BrandRemoteDataSource.self)!
            )
        }.inObjectScope(.container)
        
        container.register(GetBrandsUseCase.self) { r in
            GetBrandsUseCaseImpl(repository: r.resolve(BrandRepository.self)!)
        }.inObjectScope(.graph)
        
        container.register(BrandsViewModel.self) { r in
            BrandsViewModel(
                getBrandsUseCase: r.resolve(GetBrandsUseCase.self)!
            )
        }.inObjectScope(.transient)
    }
}
