//
//  CreateCartUseCase.swift
//  Shopped-In
//
//  Created by Omar Abdelaziz on 12/06/2025.
//

protocol CreateCartUseCase {
    func execute(variantId: String, quantity: Int, completion: @escaping (CartOperationResponse) -> Void)
}

class CreateCartUseCaseImpl: CreateCartUseCase {
    private let repository: CartRepository

    init(repository: CartRepository) {
        self.repository = repository
    }

    func execute(variantId: String, quantity: Int, completion: @escaping (CartOperationResponse) -> Void) {
        repository.createCart(variantId: variantId, quantity: quantity, completion: completion)
    }
}
