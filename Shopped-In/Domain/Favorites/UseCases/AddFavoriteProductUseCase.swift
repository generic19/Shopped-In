class AddFavoriteProductUseCase{
    private let repository: FavoriteRepository
    
    init(favoriteProductRepository: FavoriteRepository) {
        self.repository = favoriteProductRepository
    }
    
    
       func addFavorite(product: Product, completion: @escaping (Error?) -> Void) {
           repository.addToFavorite(product: product, completion: completion)
       }
}
