//
//  SetDiscountCode.swift
//  Shopped-In
//
//  Created by Omar Abdelaziz on 17/06/2025.
//

protocol SetDiscountCodeUseCase {
    func execute(cartId: String, code: String, completion: @escaping (CartOperationResponse) -> Void)
}

class SetDiscountCodeUseCaseImpl: SetDiscountCodeUseCase {
    private let repository: CartRepository

    init(repository: CartRepository) {
        self.repository = repository
    }

    func execute(cartId: String, code: String, completion: @escaping (CartOperationResponse) -> Void) {
        repository.addDiscountCode(cartId: cartId, code: code, completion: completion)
    }
}
