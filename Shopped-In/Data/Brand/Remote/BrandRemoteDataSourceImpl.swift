//
//  BrandRemoteDataSourceImpl.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 31/05/2025.
//

import Buy

final class BrandRemoteDataSourceImpl: BrandRemoteDataSource {
    private let service: APIService
    
    init(service: APIService) {
        self.service = service
    }
    
    func getAllBrands(sort: BrandsSort, forceNetwork: Bool, completion: @escaping (Result<[BrandDTO], Error>) -> Void) {
        let (sortKey, reversed): (Storefront.CollectionSortKeys?, Bool) = switch sort {
            case .title: (.title, false)
            case .mostRecent: (.updatedAt, true)
            case .relevance: (.relevance, false)
        }
        
        let query = Storefront.buildQuery {
            $0.collections(
                first: 100,
                reverse: reversed,
                sortKey: sortKey,
                query: "-title:MEN -title:WOMEN -title:KID -title:SALE",
            ) {
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
            cachePolicy: forceNetwork ?
                .networkFirst(expireIn: 24*3600) :
                    .cacheFirst(expireIn: 24*3600),
        ) { q, error in
            if let collections = q?.collections.nodes {
                completion(.success(collections))
            } else {
                print("problem with ", query.description)
                completion(.failure(error ?? .noData))
            }
        }.resume()
    }
}
