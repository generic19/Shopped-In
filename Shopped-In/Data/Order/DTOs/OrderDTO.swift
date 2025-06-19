//
//  OrderDTO.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 17/06/2025.
//

struct OrderDTO: Decodable {
    struct LineItems: Decodable {
        let nodes: [LineItemDTO]
    }
    
    let currencyCode: String
    let discountCodes: [String]
    let id: String
    let lineItems: LineItems
    
    let shippingAddress: ShippingAddress
    let totalDiscounts: String
    let totalPrice: String
}
