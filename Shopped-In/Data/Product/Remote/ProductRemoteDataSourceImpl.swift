//
//  ProductRemoteDataSourceImpl.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 31/05/2025.
//

import Buy

final class ProductRemoteDataSourceImpl: ProductRemoteDataSource {
    private let service: APIService
    
    init(service: APIService) {
        self.service = service
    }
    
    func getProductsForBrand(brandID: String, completion: @escaping (Result<[ProductListItem], any Error>) -> Void) {
        let query = Storefront.buildQuery {
            $0.collection(id: .init(rawValue: brandID)) {
                $0.products(first: 100, sortKey: .bestSelling) {
                    $0.nodes {
                        $0.id()
                        .title()
                        .featuredImage {
                            $0.url()
                        }
                        .priceRange {
                            $0.minVariantPrice {
                                $0.amount()
                                .currencyCode()
                            }
                        }
                    }
                }
            }
        }
        
        service.client.queryGraphWith(query, cachePolicy: .cacheFirst(expireIn: 30)) { query, error in
            if let dtos = query?.collection?.products.nodes {
                let products = dtos.compactMap { $0.toDomainListItem() }
                completion(.success(products))
            } else {
                completion(.failure(error ?? .noData))
            }
        }.resume()
    }
}
