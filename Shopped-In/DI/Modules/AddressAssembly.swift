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
        
        container.register(AddAddressUseCase.self) { r in
            AddAddressUseCaseImpl(repository: r.resolve(AddressRepository.self)!)
        }.inObjectScope(.graph)
        
        container.register(DeleteAddressUseCase.self) { r in
            DeleteAddressUseCaseImpl(repository: r.resolve(AddressRepository.self)!)
        }.inObjectScope(.graph)
        
        container.register(GetAddressesUseCase.self) { r in
            GetAddressesUseCaseImpl(repository: r.resolve(AddressRepository.self)!)
        }.inObjectScope(.graph)
        
        container.register(SetDefaultAddressUseCase.self) { r in
            SetDefaultAddressUseCaseImpl(repository: r.resolve(AddressRepository.self)!)
        }.inObjectScope(.graph)
        
        container.register(UpdateAddressUseCase.self) { r in
            UpdateAddressUseCaseImpl(repository: r.resolve(AddressRepository.self)!)
        }.inObjectScope(.graph)
        
        container.register(AddressViewModel.self) { r in
            AddressViewModel(
                getAddressUseCase: r.resolve(GetAddressesUseCase.self)!,
                deleteAddressUseCase: r.resolve(DeleteAddressUseCase.self)!,
                setDefaultAddressUseCase: r.resolve(SetDefaultAddressUseCase.self)!,
                getCustomerAccessTokenUseCase: r.resolve(GetCustomerAccessTokenUseCase.self)!,
            )
        }.inObjectScope(.transient)
        
        container.register(AddressFormViewModel.self) { r in
            AddressFormViewModel(
                addAddressUseCase: r.resolve(AddAddressUseCase.self)!,
                updateAddressUseCase: r.resolve(UpdateAddressUseCase.self)!,
                getCustomerAccessTokenUseCase: r.resolve(GetCustomerAccessTokenUseCase.self)!
            )
        }.inObjectScope(.transient)
    }
}
