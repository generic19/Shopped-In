import Foundation

extension OrderDTO {
    func toDomain() -> Order {
        let currency: Currency = .init(rawValue: currencyCode) ?? .EGP
        
        let discount = totalDiscounts.asAmount(currency)
        let total = totalPrice.asAmount(currency)
        let subtotal = total + discount ?? 0.0.asAmount(currency)
        
        return Order(
            id: id,
            items: lineItems.nodes.compactMap({ line in
                Order.Item(
                    productID: line.variant.product.id,
                    variantID: line.variant.id,
                    productTitle: line.variant.product.title,
                    variantTitle: line.variant.id,
                    unitPrice: line.variant.price.asAmount(currency),
                    totalPrice: line.originalTotal.asAmount(currency),
                    image: URL(string: line.variant.product.featuredImage.url)
                )
            }),
            discountCodes: discountCodes,
            subtotal: subtotal,
            discount: discount,
            total: total,
        )
    }
}

extension Double {
    func asAmount(_ currency: Currency) -> Amount {
        return Amount(value: self, currency: currency)
    }
}

extension String {
    func asAmount(_ currency: Currency) -> Amount {
        return (Double(self) ?? 0).asAmount(currency)
    }
}
