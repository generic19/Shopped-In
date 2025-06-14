
protocol UpdateCartItemQuantityUseCase {
    func execute(cartId: String, lineItemId: String, quantity: Int, completion: @escaping (CartOperationResponse) -> Void)
}

class UpdateCartItemQuantityUseCaseImpl: UpdateCartItemQuantityUseCase {
    private let repository: CartRepository

    init(repository: CartRepository) {
        self.repository = repository
    }

    func execute(cartId: String, lineItemId: String, quantity: Int, completion: @escaping (CartOperationResponse) -> Void) {
        repository.updateItemQuantity(cartId: cartId, lineItemId: lineItemId, quantity: quantity, completion: completion)
    }
}
