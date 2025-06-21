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
        
        container.register(AddToCartUseCase.self) { r in
            AddToCartUseCaseImpl(repository: r.resolve(CartRepository.self)!)
        }.inObjectScope(.graph)
        
        container.register(CreateCartUseCase.self) { r in
            CreateCartUseCaseImpl(repository: r.resolve(CartRepository.self)!)
        }.inObjectScope(.graph)
        
        container.register(DeleteCartUseCase.self) { r in
            DeleteCartUseCaseImpl(repo: r.resolve(CartRepository.self)!)
        }.inObjectScope(.graph)
        
        container.register(GetCartItemsUseCase.self) { r in
            GetCartItemsUseCaseImpl(repository: r.resolve(CartRepository.self)!)
        }.inObjectScope(.graph)
        
        container.register(RemoveFromCartUseCase.self) { r in
            RemoveFromCartUseCaseImpl(repository: r.resolve(CartRepository.self)!)
        }.inObjectScope(.graph)
        
        container.register(SetDiscountCodeUseCase.self) { r in
            SetDiscountCodeUseCaseImpl(repository: r.resolve(CartRepository.self)!)
        }.inObjectScope(.graph)
        
        container.register(UpdateCartItemQuantityUseCase.self) { r in
            UpdateCartItemQuantityUseCaseImpl(repository: r.resolve(CartRepository.self)!)
        }.inObjectScope(.graph)
        
        container.register(CartViewModel.self) { r in
            CartViewModel(
                getCartItemsUseCase: r.resolve(GetCartItemsUseCase.self)!,
                createCartUseCase: r.resolve(CreateCartUseCase.self)!,
                deleteCartUseCase: r.resolve(DeleteCartUseCase.self)!,
                addToCartUseCase: r.resolve(AddToCartUseCase.self)!,
                removeFromCartUseCase: r.resolve(RemoveFromCartUseCase.self)!,
                updateCartItemQuantityUseCase: r.resolve(UpdateCartItemQuantityUseCase.self)!,
                setDiscountCodeUseCase: r.resolve(SetDiscountCodeUseCase.self)!
            )
        }.inObjectScope(.transient)
    }
}
