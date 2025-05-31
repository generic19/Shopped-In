
import Foundation

enum Currency: String {
    case EGP
    case USD
}

struct Amount {
    let value: Double
    let currency: Currency
}

struct ProductListItem {
    let id: String
    let title: String
    let image: URL?
    let price: Amount
}
