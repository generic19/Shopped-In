
import SwiftUI

final class BrandProductsViewModel: ObservableObject {
    let getProductsByBrandUseCase: GetProductsByBrandUseCase
    
    @Published var brand: Brand?
    @Published var products = [ProductListItem]()
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init(getProductsByBrandUseCase: GetProductsByBrandUseCase) {
        self.getProductsByBrandUseCase = getProductsByBrandUseCase
    }
    
    func getProducts(brand: Brand) {
        self.brand = brand
        self.isLoading = true
        self.errorMessage = nil
        
        getProductsByBrandUseCase.execute(brand: brand) { response in
            self.isLoading = false
            
            switch response {
                case .success(let products):
                    self.errorMessage = nil
                    self.products = products
                    
                case .error(let message):
                    self.errorMessage = message
            }
        }
    }
}
