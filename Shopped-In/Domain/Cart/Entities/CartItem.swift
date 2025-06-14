import Foundation

struct CartItem: Equatable {
    let id: String
    let title: String
    let variantTitle: String
    let quantity: Int
    let price: Double
    let imageURL: URL?
    let variantId: String
    let availableQuantity: Int
}
