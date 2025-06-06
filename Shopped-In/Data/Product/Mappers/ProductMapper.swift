
import Foundation

extension ProductDTO {
    enum RawProductType: String {
        case shoes = "SHOES"
        case tShirts = "T-SHIRTS"
        case accessories = "ACCESSORIES"
    }
    
    // NOTE: Store marked men's shoes as women's and vice versa.
    enum RawCollectionTitle: String {
        case men = "WOMEN"
        case women = "MEN"
        case kids = "KID"
        case sale = "SALE"
    }
    
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
    
    func toDomainCategorizedListItem() -> CategorizedProductListItem? {
        let item = toDomainListItem()
        
        let category: Category? = {
            var demogprahic: Demographic?
            var onSale = false
            
            self.collections.nodes
                .compactMap({ RawCollectionTitle(rawValue: $0.title) })
                .forEach { rawCollection in
                    switch rawCollection {
                        case .men: demogprahic = .men
                        case .women: demogprahic = .women
                        case .kids: demogprahic = .kids
                        case .sale: onSale = true
                    }
                }
            
            let type: ProductType? = switch RawProductType(rawValue: self.productType) {
                case .shoes: .shoes
                case .tShirts: .shirts
                case .accessories: .accessories
                default: nil
            }
            
            guard let type = type else { return nil }
            return Category(demographic: demogprahic, productType: type, onSale: onSale)
        }()
        
        return if let category = category {
            CategorizedProductListItem(item: item, category: category)
        } else {
            nil
        }
    }
}
