//
//  Cart.swift
//  Shopped-In
//

struct Cart {
    let id: String
    let items: [CartItem]
    let subtotal: Double
    let total: Double
    let discount: Discount?
    let totalQuantity: Int
    
    var discountAmount: Double? { discount?.actualDiscountAmount }
}
