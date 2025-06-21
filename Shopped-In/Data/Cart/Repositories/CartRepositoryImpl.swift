
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
    private var local: CartSessionLocalDataSource

    init(remote: CartRemoteDataSource, local: CartSessionLocalDataSource) {
        self.remote = remote
        self.local = local
    }

    func createCart(variantId: String, quantity: Int, completion: @escaping (CartOperationResponse) -> Void) {
        remote.createCart(variantId: variantId, quantity: quantity) { response in
            switch response {
                case .success(let cartId):
                    self.local.cartId = cartId
                case .failure(let error):
                    completion(.failure(error))
                case .errorMessage(let message):
                    completion(.errorMessage(message))
            }
        }
    }

    func fetchCart(completion: @escaping (Result<Cart, Error>) -> Void) {
        guard let id = local.cartId else {
            completion(.failure(CartError.noCartFound))
            return
        }
        
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

    func addItem(variantId: String, quantity: Int, completion: @escaping (CartOperationResponse) -> Void) {
        if let cartId = local.cartId {
            remote.addItem(to: cartId, variantId: variantId, quantity: quantity, completion: completion)
        } else {
            remote.createCart(variantId: variantId, quantity: quantity) { response in
                switch response {
                    case .success(let cartId):
                        self.local.cartId = cartId
                        completion(.success)
                        
                    case .failure(let error):
                        completion(.failure(error))
                        
                    case .errorMessage(let string):
                        completion(.errorMessage(string))
                }
            }
        }
    }

    func updateItemQuantity(lineItemId: String, quantity: Int, completion: @escaping (CartOperationResponse) -> Void) {
        guard let cartId = local.cartId else {
            completion(.failure(CartError.noCartFound))
            return
        }
        
        remote.updateItemQuantity(cartId: cartId, lineItemId: lineItemId, quantity: quantity, completion: completion)
    }

    func removeItem(lineItemId: String, completion: @escaping (CartOperationResponse) -> Void) {
        guard let cartId = local.cartId else {
            completion(.failure(CartError.noCartFound))
            return
        }
        
        remote.removeItem(cartId: cartId, lineItemId: lineItemId, completion: completion)
    }

    func addDiscountCode(code: String, completion: @escaping (CartOperationResponse) -> Void) {
        guard let cartId = local.cartId else {
            completion(.failure(CartError.noCartFound))
            return
        }
        
        remote.addDiscountCode(cartId: cartId, code: code, completion: completion)
    }
    
    func deleteCart() {
        local.clear()
    }
}

enum CartError: LocalizedError {
    case noCartFound
    
    var errorDescription: String? {
        return switch self {
            case .noCartFound:
                "Cart must be created before it is used."
        }
    }
}
