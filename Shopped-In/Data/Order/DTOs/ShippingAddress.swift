//
//  ShippingAddress.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 17/06/2025.
//


struct ShippingAddress: Decodable {
    let address1: String
    let address2: String?
    let city: String
    let firstName: String
    let lastName: String
    let phone: String
}
