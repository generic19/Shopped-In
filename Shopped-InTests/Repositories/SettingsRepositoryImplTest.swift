//
//  SettingsRepositoryImplTest.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 26/06/2025.
//
import XCTest
import Buy
@testable import Shopped_In

fileprivate class MockCurrencyRemoteDataSource: CurrencyRemoteDataSource {
    private(set) var getUSDPriceCalled = false
    var capturedCompletion: ((Result<Double, Error>) -> Void)?

    func getUSDPrice(completion: @escaping (Result<Double, Error>) -> Void) {
        getUSDPriceCalled = true
        capturedCompletion = completion
    }
}

final class SettingsRepositoryImplTests: XCTestCase {
    private let currencyKey = "selectedCurrency"

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: currencyKey)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: currencyKey)
        super.tearDown()
    }

    func testGetUSDExchangeRate_InvokesRemoteAndForwardsSuccess() {
        let mockRemote = MockCurrencyRemoteDataSource()
        let repo = SettingsRepositoryImpl(remote: mockRemote)
        var resultValue: Double?
        var resultError: Error?

        repo.getUSDExchangeRate { result in
            switch result {
            case .success(let value): resultValue = value
            case .failure(let error): resultError = error
            }
        }

        XCTAssertTrue(mockRemote.getUSDPriceCalled,
                      "Expected getUSDPrice to be called on the remote data source")

        let expectedRate = 2.5
        mockRemote.capturedCompletion?(.success(expectedRate))

        XCTAssertNil(resultError, "Did not expect an error on success path")
        XCTAssertEqual(resultValue, expectedRate,
                       "Expected repository to forward the USD rate on success")
    }

    func testGetUSDExchangeRate_ForwardsFailure() {
        let mockRemote = MockCurrencyRemoteDataSource()
        let repo = SettingsRepositoryImpl(remote: mockRemote)
        var resultValue: Double?
        var resultError: Error?

        repo.getUSDExchangeRate { result in
            switch result {
            case .success(let value): resultValue = value
            case .failure(let error): resultError = error
            }
        }

        let testError = TestError.sampleError
        mockRemote.capturedCompletion?(.failure(testError))

        XCTAssertNil(resultValue, "Did not expect a value on failure path")
        XCTAssertNotNil(resultError, "Expected an error on failure path")
        XCTAssertTrue((resultError as? TestError) == testError,
                      "Expected repository to forward the specific error")
    }

    func testGetCurrentCurrency_DefaultsToEGPWhenNoneSaved() {
        let repo = SettingsRepositoryImpl(remote: MockCurrencyRemoteDataSource())
        let currency = repo.getCurrentCurrency()
        XCTAssertEqual(currency, "EGP",
                       "Expected default currency to be EGP when nothing is saved")
    }

    func testSaveCurrentCurrency_PersistsToUserDefaults() {
        let repo = SettingsRepositoryImpl(remote: MockCurrencyRemoteDataSource())
        let newCurrency = "USD"

        repo.saveCurrentCurrency(currency: newCurrency)

        let stored = UserDefaults.standard.string(forKey: currencyKey)
        XCTAssertEqual(stored, newCurrency,
                       "Expected saveCurrentCurrency to write the given value to UserDefaults")
    }

    func testClearCurrentCurrency_RemovesFromUserDefaults() {
        UserDefaults.standard.set("USD", forKey: currencyKey)
        let repo = SettingsRepositoryImpl(remote: MockCurrencyRemoteDataSource())

        repo.clearCurrentCurrency()

        XCTAssertNil(UserDefaults.standard.string(forKey: currencyKey),
                     "Expected clearCurrentCurrency to remove the value from UserDefaults")
    }
}
