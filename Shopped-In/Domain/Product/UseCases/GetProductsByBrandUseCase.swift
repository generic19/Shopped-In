import Foundation

protocol GetProductsByBrandUseCase {
    func execute(brand: Brand, sort: ProductsSort, completion: @escaping (CategorizedProductsResponse) -> Void)
}

class GetProductsByBrandUseCaseImpl: GetProductsByBrandUseCase {
    private let repository: ProductRepository

    init(repository: ProductRepository) {
        self.repository = repository
    }

    func execute(brand: Brand, sort: ProductsSort, completion: @escaping (CategorizedProductsResponse) -> Void) {
        repository.getProductsByBrand(brandID: brand.id, sort: sort, completion: completion)
    }
}
