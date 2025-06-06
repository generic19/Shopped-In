
class GetProductsUseCase {
    let repository: ProductRepository
    
    init(repository: ProductRepository) {
        self.repository = repository
    }
    
    func execute(sort: ProductsSort, completion: @escaping (CategorizedProductsResponse) -> Void) {
        repository.getProducts(sort: sort, completion: completion)
    }
}
