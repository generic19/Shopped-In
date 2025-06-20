//
//  GetCurrencyUseCase.swift
//  Shopped-In
//
//  Created by Omar Abdelaziz on 20/06/2025.
//



class GetCurrencyUseCase {
    let settingsRepo: SettingsRepository

    init(settingsRepo: SettingsRepository) {
        self.settingsRepo = settingsRepo
    }

    func execute() -> String{
        return settingsRepo.getCurrentCurrency()
    }
}
