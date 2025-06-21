
protocol CheckFavoriteProductUseCase {
    func execute(productID: String, completion: @escaping (Bool) -> Void)
}

class CheckFavoriteProductUseCaseImpl: CheckFavoriteProductUseCase {
    private let repository: FavoriteRepository
    
    init(favoriteProductRepository: FavoriteRepository) {
        self.repository = favoriteProductRepository
    }
    
    func execute(productID: String, completion: @escaping (Bool) -> Void) {
        repository.isFavorite(productID: productID, completion: completion)
    }
}
