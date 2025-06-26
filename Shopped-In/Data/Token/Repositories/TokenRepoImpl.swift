//
//  KeychainRepo.swift
//  Shopped-In
//
//  Created by Omar Abdelaziz on 01/06/2025.
//

final class TokenRepoImpl : TokenRepo{
    private let keychain: KeychainHelperProtocol
    
    private let service = "com.shoppedin.auth"
    private let account = "customerAccessToken"

    init(keychain: KeychainHelperProtocol) {
        self.keychain = keychain
    }
    
    func saveToken(_ token: String) {
        keychain.save(token, service: service, account: account)
    }

    func loadToken() -> String? {
        return keychain.load(service: service, account: account)
    }

    func deleteToken() {
        keychain.delete(service: service, account: account)
    }
}
