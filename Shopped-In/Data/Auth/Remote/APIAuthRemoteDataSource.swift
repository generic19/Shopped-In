//
//  ApiAuthRemoteDataSource.swift
//  Shopped-In
//
//  Created by Ayatullah Salah on 08/06/2025.
//
protocol APIAuthRemoteDataSource{
    func createCustomer(email: String, password: String, phone: String, firstName: String, lastName: String,completion: @escaping (Result<String, Error>) -> Void)
    func signInCustomer(email: String, password: String,completion: @escaping (Result<String, Error>) -> Void)
    func signOutCustomer(token: String,completion: @escaping () -> Void)
    
    
}
