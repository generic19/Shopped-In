
class FetchProductUseCase {
    private let repository: ProductRepository
    
    init(repository: ProductRepository) {
        self.repository = repository
    }
    
    func execute(id: String, completion: @escaping (Product?) -> Void) {
        repository.fetchProduct(by: id, completion: completion)
    }
}
