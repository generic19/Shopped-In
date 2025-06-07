
import Foundation
import Buy

final class BrandRepositoryImpl: BrandRepository {
    private let remote: BrandRemoteDataSource
    
    init(remote: BrandRemoteDataSource) {
        self.remote = remote
    }
    
    func getAllBrands(sort: BrandsSort, forceNetwork: Bool, completion: @escaping (BrandsResponse) -> Void) {
        remote.getAllBrands(sort: sort, forceNetwork: forceNetwork) { result in
            switch result {
                case .success(let dtos):
                    let brands = dtos.compactMap({ $0.toDomain() })
                    completion(.success(brands))
                
                case .failure(let error):
                    let message = (error as? Graph.QueryError).message(object: "brands")
                    completion(.error(message))
            }
        }
    }
}
