//
//  OrderRequests.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 17/06/2025.
//
import Foundation

struct OrderCreateRequest: AlamofireAPIService.GraphQLRequest {
    typealias ResponseType = OrderCreateResponse
    
    struct Discount {
        enum DiscountPolicy {
            case fraction(Double)
            case fixed(Double, currency: String)
        }
        
        let code: String
        let policy: DiscountPolicy
    }
    
    struct Order {
        struct LineItem {
            let variantID: String
            let quantity: Int
        }
        
        let currencyCode: String
        let lineItems: [LineItem]
        let shippingAddress: ShippingAddress
        let paymentAmount: Amount
    }
    
    let sendReceipt: Bool = false
    let customerID: String
    let discount: Discount?
    let order: Order
    
    var body: String {
        let discountFragment: String = if let discount {
            switch discount.policy {
                case .fraction(let fraction):
                    """
                        discountCode: {
                            itemPercentageDiscountCode: { code: "\(discount.code)", percentage: \(String(format: "%.2f", fraction * 100)) }
                        }
                    """
                case .fixed(let amount, let currency):
                    """
                        discountCode: {
                            itemFixedDiscountCode: {
                                code: "\(discount.code)"
                                amountSet: { shopMoney: { amount: "\(String(format: "%.2f", amount))", currencyCode: \(currency) } }
                            }
                        }
                    """
            }
        } else { "" }
        
        let itemsFragment = order.lineItems.map { item in
            """
                {
                    variantId: "\(item.variantID)",
                    quantity: \(item.quantity)
                }
            """
        }.joined(separator: ", ")
        
        let address2Fragment = if let address2 = order.shippingAddress.address2, !address2.isEmpty {
            "address2: \"\(address2)\""
        } else { "" }
        
        return """
            mutation OrderCreate {
                orderCreate(
                    order: {
                        customer: { toAssociate: { id: "\(customerID)" } }
                        \(discountFragment)
                        shippingAddress: {
                            address1: "\(order.shippingAddress.address1)"
                            \(address2Fragment)
                            city: "\(order.shippingAddress.city)"
                            countryCode: EG
                            firstName: "\(order.shippingAddress.firstName)"
                            lastName: "\(order.shippingAddress.lastName)"
                            phone: "\(order.shippingAddress.phone)"
                        }
                        currency: \(order.currencyCode)
                        financialStatus: PAID
                        lineItems: [
                            \(itemsFragment)
                        ]
                        transactions: {
                            amountSet: {
                                shopMoney: {
                                    amount: "\(String(format: "%.2f", order.paymentAmount.value))"
                                    currencyCode: \(order.paymentAmount.currency)
                                }
                            }
                        }
                    },
                    options: {
                        inventoryBehaviour: DECREMENT_IGNORING_POLICY
                        sendReceipt: true
                    }
                ) {
                    order {
                        currencyCode
                        discountCodes
                        id
                        lineItems(first: 50) {
                            nodes {
                                quantity
                                variant {
                                    id
                                    price
                                    title
                                    product {
                                        id
                                        title
                                        featuredImage {
                                            url
                                        }
                                    }
                                }
                                originalTotal
                            }
                        }
                        shippingAddress {
                            address1
                            address2
                            city
                            country
                            firstName
                            lastName
                            phone
                        }
                        totalDiscounts
                        totalPrice
                    }
                    userErrors {
                        field
                        message
                    }
                }
            }
        """
    }
}

struct OrdersRequest: AlamofireAPIService.GraphQLRequest {
    typealias ResponseType = OrdersResponse
    
    let customerID: String
    let limit: Int
    
    private var customerUUID: String {
        if let url = URL(string: customerID) {
            return url.lastPathComponent
        } else {
            return customerID
        }
    }
    
    var body: String {
        return """
            query Order {
                orders(first: \(limit), query: "customer_id:\(customerUUID)", reverse: true) {
                    nodes {
                        currencyCode
                        discountCodes
                        id
                        lineItems(first: 50) {
                            nodes {
                                quantity
                                variant {
                                    id
                                    price
                                    title
                                    product {
                                        id
                                        title
                                        featuredImage {
                                            url
                                        }
                                    }
                                }
                                originalTotal
                            }
                        }
                        shippingAddress {
                            address1
                            address2
                            city
                            country
                            firstName
                            lastName
                            phone
                        }
                        totalDiscounts
                        totalPrice
                    }
                }
            }
        """
    }
}
