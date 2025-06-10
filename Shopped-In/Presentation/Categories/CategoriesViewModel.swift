
import Combine
import Foundation

class CategoriesViewModel: ObservableObject {
    let getProductsUseCase: GetProductsUseCase
    
    @Published var categoryFilter = CategoryFilter(demographic: nil, productType: nil, onSale: nil)
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var sort: ProductsSort = .bestSellers {
        didSet { loadProducts() }
    }
    
    @Published private var categorizedProducts: [CategorizedProductListItem]?
    @Published private var categoryFilteredProducts: [ProductListItem]?
    
    @Published var query = ""
    @Published private(set) var products: [ProductListItem]?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(getProductsUseCase: GetProductsUseCase) {
        self.getProductsUseCase = getProductsUseCase
        
        $categorizedProducts
            .combineLatest($categoryFilter, { products, categoryFilter in
                products?
                    .filter({ categorizedItem in
                        let itemCategory = categorizedItem.category
                        
                        if let demographic = categoryFilter.demographic, demographic != itemCategory.demographic { return false }
                        if let productType = categoryFilter.productType, productType != itemCategory.productType { return false }
                        if let onSale = categoryFilter.onSale, onSale != itemCategory.onSale { return false }
                        
                        return true
                    })
                    .map({ $0.item })
            })
            .assign(to: &$categoryFilteredProducts)
            
        $query.debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .combineLatest($categoryFilteredProducts) { query, products in
                query.isEmpty
                    ? products
                    : products?.filter {
                        $0.title.localizedCaseInsensitiveContains(query)
                    }
            }
            .assign(to: &$products)
    }
    
    func loadProducts() {
        self.isLoading = true
        self.errorMessage = nil
        
        getProductsUseCase.execute(sort: self.sort) { response in
            self.isLoading = false
            
            switch response {
                case .success(let products):
                    self.errorMessage = nil
                    self.categorizedProducts = products
                    
                case .error(let message):
                    self.errorMessage = message
            }
        }
    }
}
