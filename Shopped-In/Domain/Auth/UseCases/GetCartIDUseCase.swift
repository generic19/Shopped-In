//
//  GetCartIDUseCase.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 19/06/2025.
//

class GetCartIDUseCase {
    func execute() -> String? {
        return CartSessionRepo.cartId
    }
}
