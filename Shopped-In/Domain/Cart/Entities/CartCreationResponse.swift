//
//  CartCreationResponse.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 26/06/2025.
//


enum CartCreationResponse {
    case success(cartId: String)
    case failure(Error)
    case errorMessage(String)
}
