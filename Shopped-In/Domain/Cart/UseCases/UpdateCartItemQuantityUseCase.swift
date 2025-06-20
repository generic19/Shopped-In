
protocol UpdateCartItemQuantityUseCase {
    func execute(lineItemId: String, quantity: Int, completion: @escaping (CartOperationResponse) -> Void)
}

class UpdateCartItemQuantityUseCaseImpl: UpdateCartItemQuantityUseCase {
    private let repository: CartRepository

    init(repository: CartRepository) {
        self.repository = repository
    }

    func execute(lineItemId: String, quantity: Int, completion: @escaping (CartOperationResponse) -> Void) {
        repository.updateItemQuantity(lineItemId: lineItemId, quantity: quantity, completion: completion)
    }
}
