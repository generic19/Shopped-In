
protocol SettingsRepository {
    func getUSDExchangeRate(completion: @escaping (Result<Double, any Error>) -> Void)
    
    func getCurrentCurrency() -> String
    
    func saveCurrentCurrency(currency: String)
    
    func clearCurrentCurrency()
}
