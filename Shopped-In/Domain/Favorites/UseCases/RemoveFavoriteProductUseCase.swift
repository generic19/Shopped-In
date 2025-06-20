class RemoveFavoriteProductUseCase{
    private let repository: FavoriteRepository
    
    init(favoriteProductRepository: FavoriteRepository) {
        self.repository = favoriteProductRepository
    }
    
    
    func removeFavorite(productID: String, completion: @escaping (Error?) -> Void) {
            repository.removeFromFavorite(productID: productID, completion: completion)
        }
}
