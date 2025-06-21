import Foundation

private struct CachedCurrencyResponse: Codable {
    let data: Data
    let timestamp: TimeInterval
}

struct CurrencyRemoteDataSourceImpl: CurrencyRemoteDataSource {
    static let urlString = "https://api.exchangeratesapi.io/v1/latest?access_key=\(EXCHANGE_RATE_API_KEY)"

    func getUSDPrice(completion: @escaping (Result<Double, Error>) -> Void) {
        let cacheKey = "CurrencyCache"
        let now = Date().timeIntervalSince1970
        let oneDay: TimeInterval = 86400

        if let saved = UserDefaults.standard.data(forKey: cacheKey),
           let cached = try? JSONDecoder().decode(CachedCurrencyResponse.self, from: saved),
           now - cached.timestamp < oneDay {
            do {
                let json = try JSONDecoder().decode(CurrencyDTO.self, from: cached.data)
                let result = (json.rates["USD"] ?? 51) / (json.rates["EGP"] ?? 1)
                completion(.success(result))
                return
            } catch {
                print("Failed to decode cached data")
            }
        }

        let url = URL(string: CurrencyRemoteDataSourceImpl.urlString)!
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data else {
                print("No data returned")
                return
            }

            do {
                let json = try JSONDecoder().decode(CurrencyDTO.self, from: data)
                let result = (json.rates["USD"] ?? 51) / (json.rates["EGP"] ?? 1)
                let cacheEntry = CachedCurrencyResponse(data: data, timestamp: now)
                if let encoded = try? JSONEncoder().encode(cacheEntry) {
                    UserDefaults.standard.set(encoded, forKey: cacheKey)
                }
                completion(.success(result))
            } catch let error as NSError {
                print("couldn't parse JSON: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
}
