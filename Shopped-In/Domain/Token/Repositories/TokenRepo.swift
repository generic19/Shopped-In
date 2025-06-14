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
