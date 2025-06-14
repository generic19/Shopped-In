
protocol GetCartItemsUseCase {
    func execute(cartId: String, completion: @escaping (Result<Cart, Error>) -> Void)
}

class GetCartItemsUseCaseImpl: GetCartItemsUseCase {
    private let repository: CartRepository

    init(repository: CartRepository) {
        self.repository = repository
    }

    func execute(cartId: String, completion: @escaping (Result<Cart, Error>) -> Void) {
        repository.fetchCart(by: cartId, completion: completion)
    }
}
