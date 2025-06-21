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
        
        container.register(CreateOrderUseCase.self) { r in
            CreateOrderUseCaseImpl(repository: r.resolve(OrderRepository.self)!)
        }.inObjectScope(.graph)
        
        container.register(GetAllOrdersUseCase.self) { r in
            GetAllOrdersUseCaseImpl(repository: r.resolve(OrderRepository.self)!)
        }.inObjectScope(.graph)
        
        container.register(GetRecentOrdersUseCase.self) { r in
            GetRecentOrdersUseCaseImpl(repository: r.resolve(OrderRepository.self)!)
        }.inObjectScope(.graph)
        
        container.register(CheckoutViewModel.self) { r in
            CheckoutViewModel(
                getCartItemsUseCase: r.resolve(GetCartItemsUseCase.self)!,
                getCustomerAccessTokenUseCase: r.resolve(GetCustomerAccessTokenUseCase.self)!,
                getCurrentUserUseCase: r.resolve(GetCurrentUserUseCase.self)!,
                getAddressesUseCase: r.resolve(GetAddressesUseCase.self)!,
                createOrderUseCase: r.resolve(CreateOrderUseCase.self)!,
                resendVerificationEmailUseCase: r.resolve(ResendVerificationEmailUseCase.self)!,
                reloadUserUseCase: r.resolve(ReloadUserUseCase.self)!,
                deleteCartUseCase: r.resolve(DeleteCartUseCase.self)!,
            )
        }.inObjectScope(.transient)
        
        container.register(OrdersViewModel.self) { r in
            OrdersViewModel(
                getAllOrdersUseCase: r.resolve(GetAllOrdersUseCase.self)!,
                getRecentOrdersUseCase: r.resolve(GetRecentOrdersUseCase.self)!,
                getCurrentUserUseCase: r.resolve(GetCurrentUserUseCase.self)!,
            )
        }
    }
}
