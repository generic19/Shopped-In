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
    
    func getProductsForBrand(brandID: String, sort: ProductsSort, completion: @escaping (Result<[ProductListItem], Error>) -> Void) {
        let (sortKey, reversed): (Storefront.ProductCollectionSortKeys, Bool) = switch sort {
            case .bestSellers: (.bestSelling, false)
            case .relevance: (.relevance, false)
            case .price: (.price, false)
            case .title: (.title, false)
            case .mostRecent: (.created, true)
        }
        
        let query = Storefront.buildQuery {
            $0.collection(id: .init(rawValue: brandID)) {
                $0.products(first: 100, reverse: reversed, sortKey: sortKey) {
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
