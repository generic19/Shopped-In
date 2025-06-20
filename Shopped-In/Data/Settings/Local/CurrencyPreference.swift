//
//  CurrencyPreference.swift
//  Shopped-In
//
//  Created by Omar Abdelaziz on 19/06/2025.
//

import Foundation

struct CurrencyPreference {
    private static let currencyKey = "selectedCurrency"

    static func save(_ currency: String) {
        UserDefaults.standard.set(currency, forKey: currencyKey)
    }

    static func load() -> String? {
        return UserDefaults.standard.string(forKey: currencyKey)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: currencyKey)
    }
}
