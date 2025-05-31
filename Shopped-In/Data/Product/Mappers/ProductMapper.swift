
import Foundation

extension ProductDTO {
    func toDomainListItem() -> ProductListItem {
        let currency: Currency = switch self.priceRange.minVariantPrice.currencyCode {
            case .egp: .EGP
            default: .USD
        }
        
        return ProductListItem(
            id: self.id.rawValue,
            title: self.title,
            image: self.featuredImage?.url,
            price: .init(
                value: Double(truncating: self.priceRange.minVariantPrice.amount as NSNumber),
                currency: currency
            )
        )
    }
}
