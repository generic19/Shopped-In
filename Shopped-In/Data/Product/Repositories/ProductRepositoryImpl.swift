
import Buy

final class ProductRepositoryImpl: ProductRepository {
    private let remote: ProductRemoteDataSource
    
    init(remote: ProductRemoteDataSource) {
        self.remote = remote
    }
    
    func getProductsByBrand(brandID: String, completion: @escaping (ProductsResponse) -> Void) {
        remote.getProductsForBrand(brandID: brandID) { result in
            switch result {
                case .success(let products):
                    completion(.success(products))
                    
                case .failure(let error):
                    let message = (error as? Graph.QueryError).message(object: "products")
                    completion(.error(message))
            }
        }
    }
    func fetchProduct(by id: String, completion: @escaping (Product?) -> Void) {
        remote.fetchProduct(by: id, completion: completion)
        }
}
