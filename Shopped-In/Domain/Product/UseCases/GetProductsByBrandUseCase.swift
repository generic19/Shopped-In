
import Foundation

final class GetProductsByBrandUseCase {
    let repository: ProductRepository
    
    init(repository: ProductRepository) {
        self.repository = repository
    }
    
    func execute(brand: Brand, completion: @escaping (ProductsResponse) -> Void) {
        repository.getProductsByBrand(brandID: brand.id, completion: completion)
    }
}
