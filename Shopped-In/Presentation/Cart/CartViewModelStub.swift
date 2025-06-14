//
//  CartViewModelStub.swift
//  Shopped-In
//
//  Created by Omar Abdelaziz on 13/06/2025.
//

import Foundation

@MainActor
class CartViewModelStub: CartViewModel {
    override init(cartRepo: CartRepository) {
        super.init(cartRepo: cartRepo)
        let items = [
            CartItem(
                id: "1",
                title: "Mock Product 1",
                quantity: 2,
                price: 150.00,
                imageURL: URL(string: "https://via.placeholder.com/100"),
                variantId: "variant_1",
                availableQuantity: 12
            ),
            CartItem(
                id: "2",
                title: "Mock Product 2",
                quantity: 1,
                price: 300.00,
                imageURL: URL(string: "https://via.placeholder.com/100"),
                variantId: "variant_2",
                availableQuantity: 10
            ),
        ]

        let totalQuantity = items.reduce(0) { $0 + $1.quantity }
        let subTotal: Double = items.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
        let discount = Discount(code: "", isApplicable: true, percentage: 20, fixedAmount: nil, actualDiscountAmount: 120)
        let total = subTotal - discount.actualDiscountAmount

        // Populate with mock data
        cart = Cart(id: "", items: items, totalQuantity: totalQuantity, subtotal: subTotal, total: total, discount: discount)

    }

    override func loadCart() {
        // No-op for stub
    }

    override func addToCart(variantId: String, quantity: Int) {
        // No-op for stub
    }

    override func removeItem(lineItemId: String) {
        // No-op for stub
    }

    override func placeOrder(addressId: String, discountCode: String?) {
        toastMessage = "Order placed successfully!"
    }
}
