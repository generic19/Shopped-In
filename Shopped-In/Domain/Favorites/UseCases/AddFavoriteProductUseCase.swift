
protocol AddFavoriteProductUseCase {
    func execute(product: Product, completion: @escaping (Error?) -> Void)
}

class AddFavoriteProductUseCaseImpl: AddFavoriteProductUseCase {
    private let repository: FavoriteRepository
    
    init(favoriteProductRepository: FavoriteRepository) {
        self.repository = favoriteProductRepository
    }
    
    func execute(product: Product, completion: @escaping (Error?) -> Void) {
        repository.addToFavorite(product: product, completion: completion)
    }
}
