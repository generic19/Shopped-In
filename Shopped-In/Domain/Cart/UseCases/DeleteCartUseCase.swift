//
//  DeleteCartUseCase.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 20/06/2025.
//

class DeleteCartUseCase {
    private let repo: CartRepository
    
    init(repo: CartRepository) {
        self.repo = repo
    }
    
    func execute() {
        repo.deleteCart()
    }
}
