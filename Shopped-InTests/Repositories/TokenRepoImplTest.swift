//
//  TokenRepoImplTest.swift
//  Shopped-In
//
//  Created by Omar Abdelaziz on 26/06/2025.
//
import XCTest
@testable import Shopped_In


class MockKeychainHelper: KeychainHelperProtocol {
    var storage = [String: String]()
    
    func save(_ value: String, service: String, account: String) {
        let key = "\(service)_\(account)"
        storage[key] = value
    }

    func load(service: String, account: String) -> String? {
        let key = "\(service)_\(account)"
        return storage[key]
    }

    func delete(service: String, account: String) {
        let key = "\(service)_\(account)"
        storage.removeValue(forKey: key)
    }
}


final class TokenRepoTests: XCTestCase {
    var sut: TokenRepoImpl!
    var mockKeychain: MockKeychainHelper!

    override func setUp() {
        super.setUp()
        mockKeychain = MockKeychainHelper()
        sut = TokenRepoImpl(keychain: mockKeychain)
    }

    func test_saveToken_shouldStoreToken() {
        sut.saveToken("abc123")
        let stored = mockKeychain.storage["com.shoppedin.auth_customerAccessToken"]
        XCTAssertEqual(stored, "abc123")
    }

    func test_loadToken_shouldReturnCorrectToken() {
        mockKeychain.storage["com.shoppedin.auth_customerAccessToken"] = "xyz789"
        let token = sut.loadToken()
        XCTAssertEqual(token, "xyz789")
    }

    func test_deleteToken_shouldRemoveToken() {
        mockKeychain.storage["com.shoppedin.auth_customerAccessToken"] = "toDelete"
        sut.deleteToken()
        XCTAssertNil(mockKeychain.storage["com.shoppedin.auth_customerAccessToken"])
    }
}
