//
//  BrandAssembly.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 20/06/2025.
//

import Swinject

class SettingsAssembly: Assembly {
    func assemble(container: Container) {
        container.register(CurrencyRemoteDataSource.self) { r in
            CurrencyRemoteDataSourceImpl()
        }.inObjectScope(.container)
        
        container.register(SettingsRepository.self) { r in
            SettingsRepositoryImpl(
                remote: r.resolve(CurrencyRemoteDataSource.self)!
            )
        }.inObjectScope(.container)
        
        container.register(GetCurrencyExchangeRateUseCase.self) { r in
            GetCurrencyExchangeRateUseCaseImpl(settingsRepo: r.resolve(SettingsRepository.self)!)
        }.inObjectScope(.graph)
        
        container.register(GetCurrencyUseCase.self) { r in
            GetCurrencyUseCaseImpl(settingsRepo: r.resolve(SettingsRepository.self)!)
        }.inObjectScope(.graph)
        
        container.register(SetCurrencyUseCase.self) { r in
            SetCurrencyUseCaseImpl(settingsRepo: r.resolve(SettingsRepository.self)!)
        }.inObjectScope(.graph)
        
        container.register(CurrencyConverter.self) { r in
            CurrencyConverter(
                getCurrencyExchangeRateUseCase: r.resolve(GetCurrencyExchangeRateUseCase.self)!,
                getCurrencyUseCase: r.resolve(GetCurrencyUseCase.self)!,
                setCurrencyUseCase: r.resolve(SetCurrencyUseCase.self)!,
            )
        }.inObjectScope(.container)
    }
}
