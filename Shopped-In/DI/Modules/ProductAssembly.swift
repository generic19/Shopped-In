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
        
        container.register(FavoriteRepository.self) { r in
            FavoriteRepositoryImpl()
        }.inObjectScope(.container)
        
        container.register(FetchProductUseCase.self) { r in
            FetchProductUseCaseImpl(repository: r.resolve(ProductRepository.self)!)
        }.inObjectScope(.graph)
        
        container.register(GetProductsByBrandUseCase.self) { r in
            GetProductsByBrandUseCaseImpl(repository: r.resolve(ProductRepository.self)!)
        }.inObjectScope(.graph)
        
        container.register(GetProductsUseCase.self) { r in
            GetProductsUseCaseImpl(repository: r.resolve(ProductRepository.self)!)
        }.inObjectScope(.graph)
        
        container.register(AddFavoriteProductUseCase.self) { r in
            AddFavoriteProductUseCaseImpl(favoriteProductRepository: r.resolve(FavoriteRepository.self)!)
        }.inObjectScope(.graph)
        
        container.register(RemoveFavoriteProductUseCase.self) { r in
            RemoveFavoriteProductUseCaseImpl(favoriteProductRepository: r.resolve(FavoriteRepository.self)!)
        }.inObjectScope(.graph)
        
        container.register(CheckFavoriteProductUseCase.self) { r in
            CheckFavoriteProductUseCaseImpl(favoriteProductRepository: r.resolve(FavoriteRepository.self)!)
        }.inObjectScope(.graph)
        
        container.register(BrandProductsViewModel.self) { r in
            BrandProductsViewModel(getProductsByBrandUseCase: r.resolve(GetProductsByBrandUseCase.self)!)
        }.inObjectScope(.transient)
        
        container.register(ProductDetailViewModel.self) { r in
            ProductDetailViewModel(
                fetchProductUseCase: r.resolve(FetchProductUseCase.self)!,
                addFavoriteUseCase: r.resolve(AddFavoriteProductUseCase.self)!,
                removeFavoriteUseCase: r.resolve(RemoveFavoriteProductUseCase.self)!,
                checkFavoriteUseCase: r.resolve(CheckFavoriteProductUseCase.self)!,
            )
        }.inObjectScope(.transient)
        
        container.register(CategoriesViewModel.self) { r in
            CategoriesViewModel(getProductsUseCase: r.resolve(GetProductsUseCase.self)!)
        }.inObjectScope(.transient)
        
        container.register(FavoriteViewModel.self) { r in
            FavoriteViewModel(
                addFavoriteUseCase: r.resolve(AddFavoriteProductUseCase.self)!,
                removeFavoriteUseCase: r.resolve(RemoveFavoriteProductUseCase.self)!,
                checkFavoriteUseCase: r.resolve(CheckFavoriteProductUseCase.self)!
            )
        }.inObjectScope(.transient)
    }
}
