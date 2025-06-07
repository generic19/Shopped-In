//
//  ProductRemoteDataSourceImpl.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 31/05/2025.
//

import Buy

final class ProductRemoteDataSourceImpl: ProductRemoteDataSource {
    let service: APIService
    
    init(service: APIService) {
        self.service = service
    }
    
    func getProductsForBrand(brandID: String, completion: @escaping (Result<[ProductListItem], Error>) -> Void) {
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
    
    
    func fetchProduct(by id: String, completion: @escaping (Product?) -> Void) {
        let gqlID = GraphQL.ID(rawValue: id)
        let query = Storefront.buildQuery { $0
            .node(id: gqlID) { $0
                .onProduct { $0
                    .title()
                    .description()
                    .options { $0.name().values() }
                    .images(first: 5) { $0.edges { $0.node { $0.url() } } }
                    .variants(first: 10) { $0.edges { $0.node {
                        $0.price { $0.amount() }
                        $0.selectedOptions { $0.name().value() }
                    }}}
                }
            }
        }
        
        service.client.queryGraphWith(query) { response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let storefrontProduct = response?.node as? Storefront.Product else {
                print("Failed to cast node as product")
                completion(nil)
                return
            }
            
            let product = ProductMapper.map(storefrontProduct: storefrontProduct)
            completion(product)
        }.resume()
    }
    
}
