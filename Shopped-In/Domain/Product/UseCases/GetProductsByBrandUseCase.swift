
import Foundation

final class GetProductsByBrandUseCase {
    let repository: ProductRepository
    
    init(repository: ProductRepository) {
        self.repository = repository
    }
    
    func execute(brand: Brand, sort: ProductsSort, completion: @escaping (ProductsResponse) -> Void) {
        repository.getProductsByBrand(brandID: brand.id, sort: sort, completion: completion)
    }
}
