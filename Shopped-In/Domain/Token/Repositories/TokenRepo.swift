//
//  KeychainRepo.swift
//  Shopped-In
//
//  Created by Omar Abdelaziz on 01/06/2025.
//

protocol TokenRepo {    
    func saveToken(_ token: String)
    func loadToken() -> String?
    func deleteToken()
}

class StubTokenRepo : TokenRepo {
    private var tokemKey:String?
    func saveToken(_ token: String) {
        tokemKey = token
    }
    
    func loadToken() -> String? {
        return tokemKey
    }
    
    func deleteToken() {
        self.tokemKey = nil
    }
}
