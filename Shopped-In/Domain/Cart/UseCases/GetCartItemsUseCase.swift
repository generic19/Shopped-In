
protocol GetCartItemsUseCase {
    func execute(completion: @escaping (Result<Cart, Error>) -> Void)
}

class GetCartItemsUseCaseImpl: GetCartItemsUseCase {
    private let repository: CartRepository

    init(repository: CartRepository) {
        self.repository = repository
    }

    func execute(completion: @escaping (Result<Cart, Error>) -> Void) {
        repository.fetchCart(completion: completion)
    }
}
