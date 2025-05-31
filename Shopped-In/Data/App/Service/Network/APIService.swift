//
//  APIClient.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 31/05/2025.
//

import Foundation
import Buy

final class APIService {
    static let shared = APIService()
    
    static let standardRetry = Graph.RetryHandler<Storefront.QueryRoot>(
        endurance: .finite(3),
        interval: 2,
        condition: { q, _ in q != nil }
    )
    
    let client: Graph.Client
    
    private init() {
        self.client = Graph.Client(shopDomain: SHOPIFY_SHOP_DOMAIN, apiKey: STOREFRONT_API_ACCESS_TOKEN)
    }
}
