//
//  CurrencyConverter.swift
//  Shopped-In
//
//  Created by Omar Abdelaziz on 20/06/2025.
//

class CurrencyConverter {
    var usdExchangeRate: Double?

    private var getCurrencyExchangeRateUseCase: GetCurrencyExchangeRateUseCase
    private var getCurrencyUseCase: GetCurrencyUseCase
    private var setCurrencyUseCase: SetCurrencyUseCase

    init(getCurrencyExchangeRateUseCase: GetCurrencyExchangeRateUseCase, getCurrencyUseCase: GetCurrencyUseCase, setCurrencyUseCase: SetCurrencyUseCase) {
        self.getCurrencyExchangeRateUseCase = getCurrencyExchangeRateUseCase
        self.getCurrencyUseCase = getCurrencyUseCase
        self.setCurrencyUseCase = setCurrencyUseCase
        
        getUSDExchangeRate()
    }

    private func getUSDExchangeRate() {
        getCurrencyExchangeRateUseCase.execute { [weak self] result in
            switch result {
            case let .success(rate):
                self?.usdExchangeRate = rate
            case .failure:
                self?.setCurrencyUseCase.execute(currency: "EGP")
                self?.usdExchangeRate = nil
            }
        }
    }


    func getCurrency() -> String {
        guard usdExchangeRate != nil else {
            return "EGP"
        }
        return getCurrencyUseCase.execute()
    }
}
