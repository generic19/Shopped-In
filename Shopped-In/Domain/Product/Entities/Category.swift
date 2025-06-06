
struct Category {
    let demographic: Demographic?
    let productType: ProductType
    let onSale: Bool
}

struct CategoryFilter: Equatable {
    let demographic: Demographic?
    let productType: ProductType?
    let onSale: Bool?
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return (lhs.demographic == rhs.demographic
            && lhs.productType == rhs.productType
            && lhs.onSale == rhs.onSale)
    }
    
    func withDemographic(_ demographic: Demographic?) -> CategoryFilter {
        return CategoryFilter(demographic: demographic, productType: self.productType, onSale: self.onSale)
    }
    
    func withProductType(_ productType: ProductType?) -> CategoryFilter {
        return CategoryFilter(demographic: self.demographic, productType: productType, onSale: self.onSale)
    }
    
    func withOnSale(_ onSale: Bool?) -> CategoryFilter {
        return CategoryFilter(demographic: self.demographic, productType: self.productType, onSale: onSale)
    }
}

enum Demographic {
    case men
    case women
    case kids
}

enum ProductType {
    case shoes
    case shirts
    case accessories
}
