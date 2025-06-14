

import Buy
import Foundation

extension Cart {
    init?(from storefrontCart: Storefront.Cart) {
        let items = storefrontCart.lines.nodes.compactMap { node -> CartItem? in
            guard let variant = node.merchandise as? Storefront.ProductVariant else {
                return nil
            }
            return CartItem(
                id: node.id.rawValue,
                title: variant.product.title,
                variantTitle: variant.title,
                quantity: Int(node.quantity),
                price: Double(variant.price.amount),
                imageURL: variant.product.featuredImage?.url,
                variantId: variant.id.rawValue,
                availableQuantity: Int(variant.quantityAvailable ?? 0)
            )
        }

        let discount = Discount(from: storefrontCart.discountCodes, allocations: storefrontCart.discountAllocations)

        self.init(
            id: storefrontCart.id.rawValue,
            items: items,
            totalQuantity: Int(storefrontCart.totalQuantity),
            subtotal: Double(storefrontCart.cost.subtotalAmount.amount),
            total: Double(storefrontCart.cost.totalAmount.amount),
            discount: discount
        )
    }
}

extension Discount {
    init?(from codes: [Storefront.CartDiscountCode?], allocations: [CartDiscountAllocation]) {
        guard let code = codes.first??.code else { return nil }

        let isApplicable = codes.first??.applicable ?? false
        let allocation = allocations.first

        var percentage: Double?
        var fixedAmount: Double?

        if let value = allocation?.discountApplication.value {
            switch value {
            case let percent as Storefront.PricingPercentageValue:
                percentage = percent.percentage
            case let money as Storefront.MoneyV2:
                fixedAmount = Double(money.amount)
            default:
                break
            }
        }

        let actualAmount = allocation.flatMap { Double($0.discountedAmount.amount) } ?? 0.0

        self.init(
            code: code,
            isApplicable: isApplicable,
            percentage: percentage,
            fixedAmount: fixedAmount,
            actualDiscountAmount: actualAmount
        )
    }
}

extension Double {
    init(_ decimalValue: Decimal) {
        self = NSDecimalNumber(decimal: decimalValue).doubleValue
    }
}
