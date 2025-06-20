
class GetCurrencyExchangeRateUseCase {
    let settingsRepo: SettingsRepository

    init(settingsRepo: SettingsRepository) {
        self.settingsRepo = settingsRepo
    }

    func execute(completion: @escaping (Result<Double, Error>) -> Void) {
        settingsRepo.getUSDExchangeRate(completion: completion)
    }
}
