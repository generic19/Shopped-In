
//
//  CartRepositoryImpl.swift
//  Shopped-In
//
//  Created by Omar Abdelaziz on 11/06/2025.
//

import Buy
import Foundation

class CartRepositoryImpl: CartRepository {
    private let remote: CartRemoteDataSource

    init(remote: CartRemoteDataSource) {
        self.remote = remote
    }

    func createCart(variantId: String, quantity: Int, completion: @escaping (CartOperationResponse) -> Void) {
        remote.createCart(variantId: variantId, quantity: quantity, completion: completion)
    }

    func fetchCart(by id: String, completion: @escaping (Result<Cart, Error>) -> Void) {
        remote.fetchCart(by: id) { result in
            switch result {
            case let .success(storeFrontCart):
                let cart = Cart(from: storeFrontCart)
                guard let cart else {
                    completion(.failure(CartError.noCartFound))
                    return
                }

                completion(.success(cart))

            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func addItem(to cartId: String, variantId: String, quantity: Int, completion: @escaping (CartOperationResponse) -> Void) {
        remote.addItem(to: cartId, variantId: variantId, quantity: quantity, completion: completion)
    }

    func updateItemQuantity(cartId: String, lineItemId: String, quantity: Int, completion: @escaping (CartOperationResponse) -> Void) {
        remote.updateItemQuantity(cartId: cartId, lineItemId: lineItemId, quantity: quantity, completion: completion)
    }

    func removeItem(cartId: String, lineItemId: String, completion: @escaping (CartOperationResponse) -> Void) {
        remote.removeItem(cartId: cartId, lineItemId: lineItemId, completion: completion)
    }

    func addDiscountCode(cartId: String, code: String, completion: @escaping (CartOperationResponse) -> Void) {
        remote.addDiscountCode(cartId: cartId, code: code, completion: completion)
    }
}

enum CartError: Error {
    case noCartFound
}
