
class CheckFavoriteProductUseCase{
    private let repository: FavoriteRepository
    
    init(favoriteProductRepository: FavoriteRepository) {
        self.repository = favoriteProductRepository
    }
    
    
    func checkFavorite(productID: String, completion: @escaping (Bool) -> Void) {
           repository.isFavorite(productID: productID, completion: completion)
       }
}
