
import SwiftUI

final class BrandsViewModel: ObservableObject {
    private let getBrandsUseCase: GetBrandsUseCase
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var allBrands: [Brand]?
    @Published var query = ""
    @Published private var debouncedQuery = ""
    
    var brands: [Brand]? {
        debouncedQuery.isEmpty
            ? allBrands
            : allBrands?.filter {
                $0.title.localizedCaseInsensitiveContains(debouncedQuery)
            }
    }
    
    @Published var sort = BrandsSort.title {
        didSet {
            getBrands()
        }
    }
    
    init(getBrandsUseCase: GetBrandsUseCase) {
        self.getBrandsUseCase = getBrandsUseCase
        
        $query.debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .assign(to: &$debouncedQuery)
    }
    
    func getBrands(forceNetwork: Bool = false) {
        isLoading = true
        errorMessage = nil
        
        getBrandsUseCase.execute(sort: sort) { response in
            self.isLoading = false
            
            switch response {
                case .success(let brands):
                    self.errorMessage = nil
                    self.allBrands = brands
                    
                case .error(let message):
                    self.errorMessage = message
            }
        }
    }
}
