//
//  Cart.swift
//  Shopped-In
//
//  Created by Omar Abdelaziz on 14/06/2025.
//

import Foundation

struct Cart {
    let id: String
    let items: [CartItem]
    let totalQuantity: Int
    let subtotal: Double
    let total: Double
    let discount: Discount?
}


