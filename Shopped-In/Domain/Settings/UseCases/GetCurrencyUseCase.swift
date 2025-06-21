//
//  GetCurrencyUseCase.swift
//  Shopped-In
//
//  Created by Omar Abdelaziz on 20/06/2025.
//

protocol GetCurrencyUseCase {
    func execute() -> String
}

class GetCurrencyUseCaseImpl: GetCurrencyUseCase {
    let settingsRepo: SettingsRepository

    init(settingsRepo: SettingsRepository) {
        self.settingsRepo = settingsRepo
    }

    func execute() -> String {
        return settingsRepo.getCurrentCurrency()
    }
}
