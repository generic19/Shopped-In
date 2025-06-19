
import Foundation
import UIKit

enum Currency: String {
    case EGP
    case USD
}

struct Amount {
    let value: Double
    let currency: Currency
    
    static func +(lhs: Amount, rhs: Amount) -> Amount? {
        guard lhs.currency == rhs.currency else { return nil }
        return Amount(value: lhs.value + rhs.value, currency: lhs.currency)
    }
    
    static func -(lhs: Amount, rhs: Amount) -> Amount? {
        guard lhs.currency == rhs.currency else { return nil }
        return Amount(value: lhs.value - rhs.value, currency: lhs.currency)
    }
}

struct ProductListItem {
    let id: String
    let title: String
    let image: URL?
    let price: Amount
}
struct SelectedOption {
    let name: String
    let value: String
}

struct ColorOption {
    let name: String
    let hexCode: String
}

struct Variant {
    let id: String
    let selectedOptions: [String: String]
    let price: String
}

struct Product {
    let title: String
    let price: String
    let images: [String]
    let sizes: [String]
    let colors: [ColorOption] 
    let rating: Int
    let description: String
    let reviews: [Review]
    let variants: [Variant]
}

struct Review {
    let name: String
    let comment: String
    let avatar: UIImage
}

struct CategorizedProductListItem {
    let item: ProductListItem
    let category: Category
}
