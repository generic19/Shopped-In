//
//  RemoveFromCartUseCase.swift
//  Shopped-In
//
//  Created by Omar Abdelaziz on 12/06/2025.
//


protocol RemoveFromCartUseCase {
    func execute(lineItemId: String, completion: @escaping (CartOperationResponse) -> Void)
}

class RemoveFromCartUseCaseImpl: RemoveFromCartUseCase {
    private let repository: CartRepository

    init(repository: CartRepository) {
        self.repository = repository
    }

    func execute(lineItemId: String, completion: @escaping (CartOperationResponse) -> Void) {
        repository.removeItem(lineItemId: lineItemId, completion: completion)
    }
}
