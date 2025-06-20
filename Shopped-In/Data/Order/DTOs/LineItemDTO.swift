//
//  LineItemDTO.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 17/06/2025.
//


struct LineItemDTO: Decodable {
    struct Variant: Decodable {
        struct Product: Decodable {
            struct FeaturedImage: Decodable {
                let url: String
            }
            
            let id: String
            let title: String
            let featuredImage: FeaturedImage
        }
        
        let id: String
        let price: String
        let title: String
        let product: Product
    }
    
    let quantity: Int
    let variant: Variant
    let originalTotal: String
}
