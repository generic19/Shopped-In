
import Foundation
import UIKit
import Buy

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

struct ProductMapper {
    static func map(storefrontProduct: Storefront.Product) -> Product {
        let title = storefrontProduct.title
        let description = storefrontProduct.description

        let images = storefrontProduct.images.edges.compactMap { $0.node.url.absoluteString }
        let priceDecimal = storefrontProduct.variants.edges.first?.node.price.amount ?? Decimal(0.0)
        let price = String(describing: priceDecimal)

        var sizes: [String] = []
        var colors: [String] = []

        for option in storefrontProduct.options {
            if option.name.lowercased().contains("size") {
                sizes = option.values
            }
            if option.name.lowercased().contains("color") {
                colors = option.values
            }
        }

        let colorHexMap = [
            "burgandy": "#660033",
            "red": "#FF0000",
            "white": "#FFFFFF",
            "blue": "#0000FF",
            "black": "#000000",
            "gray": "#808080",
            "light_brown": "#A52A2A",
            "beige": "#F5F5DC",
            "yellow": "#FFFF00"
        ]
        let hexColors = colors.map { colorHexMap[$0.lowercased()] ?? "#CCCCCC" }

        let review = Review(name: "Ayatullah", comment: "Good product", avatar: UIImage(systemName: "person.fill")!)

        return Product(
            title: title,
            price: price,
            images: images,
            sizes: sizes,
            colors: hexColors,
            rating: 4,
            description: description,
            reviews: [review]
        )
    }
}
