
//
//  SetCurrencyUseCase.swift
//  Shopped-In
//
//  Created by Omar Abdelaziz on 20/06/2025.
//

protocol SetCurrencyUseCase {
    func execute(currency: String)
}

class SetCurrencyUseCaseImpl: SetCurrencyUseCase {
    let settingsRepo: SettingsRepository

    init(settingsRepo: SettingsRepository) {
        self.settingsRepo = settingsRepo
    }

    func execute(currency: String) {
        return settingsRepo.saveCurrentCurrency(currency: currency)
    }
}
