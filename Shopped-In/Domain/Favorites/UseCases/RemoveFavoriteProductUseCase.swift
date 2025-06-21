
protocol RemoveFavoriteProductUseCase {
    func execute(productID: String, completion: @escaping (Error?) -> Void)
}

class RemoveFavoriteProductUseCaseImpl: RemoveFavoriteProductUseCase {
    private let repository: FavoriteRepository
    
    init(favoriteProductRepository: FavoriteRepository) {
        self.repository = favoriteProductRepository
    }
    
    func execute(productID: String, completion: @escaping (Error?) -> Void) {
        repository.removeFromFavorite(productID: productID, completion: completion)
    }
}
