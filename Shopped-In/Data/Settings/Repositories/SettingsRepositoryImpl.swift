
class SettingsRepositoryImpl : SettingsRepository  {
    let currencyRemoteDataSource: CurrencyRemoteDataSource

    init(remote: CurrencyRemoteDataSource) {
        currencyRemoteDataSource = remote
    }

    func getUSDExchangeRate(completion: @escaping (Result<Double, any Error>) -> Void) {
        return currencyRemoteDataSource.getUSDPrice(completion: completion)
    }
    
    func getCurrentCurrency() -> String {
        return CurrencyPreference.load() ?? "EGP"
    }
    
    func saveCurrentCurrency(currency: String) {
        CurrencyPreference.save(currency)
    }
    
    func clearCurrentCurrency() {
        CurrencyPreference.clear()
    }
    
}
