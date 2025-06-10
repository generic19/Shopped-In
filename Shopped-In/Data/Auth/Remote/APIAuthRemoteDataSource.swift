//
//  ApiAuthRemoteDataSource.swift
//  Shopped-In
//
//  Created by Ayatullah Salah on 08/06/2025.
//
import Foundation
import Buy

typealias CustomerAccessToken = String

protocol APIAuthRemoteDataSource{
    func createCustomer(user: User, password: String,completion: @escaping (Error?) -> Void)
    func signInCustomer(email: String, password: String,completion: @escaping (Result<CustomerAccessToken, Error>) -> Void)
    func signOutCustomer(token: String,completion: @escaping () -> Void)
}

enum AuthError: Error {
    case noData
    case apiErrors(_ errors: [Storefront.CustomerUserError])
}

extension AuthError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .noData:
                return "API returned no data."
                
            case .apiErrors(let errors):
                return errors
                    .map { error in
                        if let fields = error.field?.joined(separator: ", ") {
                            return "[\(fields)]: \(error.message)"
                        } else {
                            return error.message
                        }
                    }
                    .joined(separator: ", ")
        }
    }
}
