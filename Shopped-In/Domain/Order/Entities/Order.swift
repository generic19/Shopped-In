import Foundation

struct Order {
    struct Item {
        let productID: String
        let variantID: String
        let productTitle: String
        let variantTitle: String
        let unitPrice: Amount
        let totalPrice: Amount
        let image: URL?
    }
    
    let id: String
    let items: [Item]
    let discountCodes: [String]
    let subtotal: Amount
    let discount: Amount
    let total: Amount
}
