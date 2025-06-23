
import SwiftUI

class BrandProductsViewModel: ObservableObject {
    let getProductsByBrandUseCase: GetProductsByBrandUseCase
    
    @Published var brand: Brand?
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published private var allProducts: [CategorizedProductListItem]?
    @Published var query = ""
    @Published var productType: ProductType?
    @Published var products: [ProductListItem]?
    
    @Published var sort: ProductsSort = .bestSellers {
        didSet {
            if let brand = brand {
                getProducts(brand: brand)
            }
        }
    }
    
    init(getProductsByBrandUseCase: GetProductsByBrandUseCase) {
        self.getProductsByBrandUseCase = getProductsByBrandUseCase
        
        let debouncedQuery = $query
            .debounce(for: .milliseconds(250), scheduler: RunLoop.main)
            .removeDuplicates()
        
        $allProducts
            .combineLatest($productType, debouncedQuery) { allProducts, productType, debouncedQuery in
                allProducts?
                    .filter { item in
                        let typeMatch = productType == nil || item.category.productType == productType
                        let titleMatch = debouncedQuery.isEmpty || item.item.title.localizedCaseInsensitiveContains(debouncedQuery)
                        
                        return typeMatch && titleMatch
                    }
                    .map(\.item)
            }
            .assign(to: &$products)
    }
    
    func getProducts(brand: Brand) {
        self.brand = brand
        self.isLoading = true
        self.errorMessage = nil
        
        getProductsByBrandUseCase.execute(brand: brand, sort: sort) { response in
            self.isLoading = false
            
            switch response {
                case .success(let products):
                    self.errorMessage = nil
                    self.allProducts = products
                    
                case .error(let message):
                    self.errorMessage = message
            }
        }
    }
}
