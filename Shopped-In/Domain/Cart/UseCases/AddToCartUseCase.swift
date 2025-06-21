

protocol AddToCartUseCase {
    func execute(variantId: String, quantity: Int, completion: @escaping (CartOperationResponse) -> Void)
}

class AddToCartUseCaseImpl: AddToCartUseCase {
    private let repository: CartRepository

    init(repository: CartRepository) {
        self.repository = repository
    }

    func execute(variantId: String, quantity: Int, completion: @escaping (CartOperationResponse) -> Void) {
        repository.addItem(variantId: variantId, quantity: quantity, completion: completion)
    }
}
