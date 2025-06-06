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
        let query = Storefront.buildQuery {
            $0.collection(id: .init(rawValue: brandID)) {
                $0.products(first: 100, reverse: sort.reversed, sortKey: sort.collectionSortKey) {
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
    
    func getProducts(sort: ProductsSort, completion: @escaping (Result<[CategorizedProductListItem], any Error>) -> Void) {
        let query = Storefront.buildQuery {
            $0.products(first: 100, reverse: sort.reversed, sortKey: sort.productSortKey) {
                $0.nodes {
                    $0.id()
                    .title()
                    .productType()
                    .featuredImage {
                        $0.url()
                    }
                    .collections(first: 100) {
                        $0.nodes {
                            $0.title()
                        }
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
        
        service.client.queryGraphWith(query, cachePolicy: .cacheFirst(expireIn: 30)) { query, error in
            if let dtos = query?.products.nodes {
                let products = dtos.compactMap { $0.toDomainCategorizedListItem() }
                completion(.success(products))
            } else {
                completion(.failure(error ?? .noData))
            }
        }.resume()
    }
}

fileprivate extension ProductsSort {
    var collectionSortKey: Storefront.ProductCollectionSortKeys {
        switch self {
            case .bestSellers: .bestSelling
            case .relevance: .relevance
            case .price: .price
            case .title: .title
            case .mostRecent: .created
        }
    }
    
    var productSortKey: Storefront.ProductSortKeys {
        switch self {
            case .bestSellers: .bestSelling
            case .relevance: .relevance
            case .price: .price
            case .title: .title
            case .mostRecent: .createdAt
        }
    }
    
    var reversed: Bool {
        switch self {
            case .mostRecent: true
            default: false
        }
    }
}
