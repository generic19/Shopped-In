//
//  SetDiscountCode.swift
//  Shopped-In
//
//  Created by Omar Abdelaziz on 17/06/2025.
//

protocol SetDiscountCodeUseCase {
    func execute(code: String, completion: @escaping (CartOperationResponse) -> Void)
}

class SetDiscountCodeUseCaseImpl: SetDiscountCodeUseCase {
    private let repository: CartRepository

    init(repository: CartRepository) {
        self.repository = repository
    }

    func execute(code: String, completion: @escaping (CartOperationResponse) -> Void) {
        repository.addDiscountCode(code: code, completion: completion)
    }
}
