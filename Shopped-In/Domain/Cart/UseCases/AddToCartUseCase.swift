

protocol AddToCartUseCase {
    func execute(cartId: String, variantId: String, quantity: Int, completion: @escaping (CartOperationResponse) -> Void)
}

class AddToCartUseCaseImpl: AddToCartUseCase {
    private let repository: CartRepository

    init(repository: CartRepository) {
        self.repository = repository
    }

    func execute(cartId: String, variantId: String, quantity: Int, completion: @escaping (CartOperationResponse) -> Void) {
        repository.addItem(to: cartId, variantId: variantId, quantity: quantity, completion: completion)
    }
}
