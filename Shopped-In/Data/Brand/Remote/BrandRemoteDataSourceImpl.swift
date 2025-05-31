//
//  BrandRemoteDataSourceImpl.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 31/05/2025.
//

import Buy

final class BrandRemoteDataSourceImpl: BrandRemoteDataSource {
    let service: APIService
    
    init(service: APIService) {
        self.service = service
    }
    
    func getAllBrands(completion: @escaping (Result<[BrandDTO], any Error>) -> Void) {
        let query = Storefront.buildQuery {
            $0.collections(first: 100, query: "-title:MEN -title:WOMEN -title:KID -title:SALE") {
                $0.nodes {
                    $0.id()
                    .title()
                    .image {
                        $0.url()
                    }
                }
            }
        }
        
        service.client.queryGraphWith(
            query,
            cachePolicy: .cacheFirst(expireIn: 24*3600),
        ) { query, error in
            if let collections = query?.collections.nodes {
                completion(.success(collections))
            } else {
                completion(.failure(error ?? .noData))
            }
        }.resume()
    }
}
