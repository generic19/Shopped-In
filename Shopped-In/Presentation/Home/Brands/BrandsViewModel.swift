
import SwiftUI

final class BrandsViewModel: ObservableObject {
    private let getBrandsUseCase: GetBrandsUseCase
    
    @Published var brands = [Brand]()
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init(getBrandsUseCase: GetBrandsUseCase) {
        self.getBrandsUseCase = getBrandsUseCase
    }
    
    func getBrands() {
        isLoading = true
        errorMessage = nil
        
        getBrandsUseCase.execute { response in
            self.isLoading = false
            
            switch response {
                case .success(let brands):
                    self.errorMessage = nil
                    self.brands = brands
                    
                case .error(let message):
                    self.errorMessage = message
            }
        }
    }
}
