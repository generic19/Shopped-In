
import SwiftUI

class BrandProductsViewModel: ObservableObject {
    let getProductsByBrandUseCase: GetProductsByBrandUseCase
    
    @Published var brand: Brand?
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published private var allProducts: [ProductListItem]?
    @Published var query = ""
    @Published private var debouncedQuery = ""
    
    var products: [ProductListItem]? {
        debouncedQuery.isEmpty
            ? allProducts
            : allProducts?.filter {
                $0.title.localizedCaseInsensitiveContains(debouncedQuery)
            }
    }
    
    @Published var sort: ProductsSort = .bestSellers {
        didSet {
            if let brand = brand {
                getProducts(brand: brand)
            }
        }
    }
    
    init(getProductsByBrandUseCase: GetProductsByBrandUseCase) {
        self.getProductsByBrandUseCase = getProductsByBrandUseCase
        
        $query.debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .assign(to: &$debouncedQuery)
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
