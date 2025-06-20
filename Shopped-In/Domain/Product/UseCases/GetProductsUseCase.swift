
protocol GetProductsUseCase {
    func execute(sort: ProductsSort, completion: @escaping (CategorizedProductsResponse) -> Void)
}

class GetProductsUseCaseImpl: GetProductsUseCase {
    private let repository: ProductRepository

    init(repository: ProductRepository) {
        self.repository = repository
    }

    func execute(sort: ProductsSort, completion: @escaping (CategorizedProductsResponse) -> Void) {
        repository.getProducts(sort: sort, completion: completion)
    }
}
