import Foundation

class ProductDetailViewModel: ObservableObject {
    @Published var product: Product? = nil
    @Published var isLoading = false
    
    private let fetchProductUseCase: FetchProductUseCase
    
    init(fetchProductUseCase: FetchProductUseCase) {
        self.fetchProductUseCase = fetchProductUseCase
    }
    
    func fetchProduct(by id: String) {
        isLoading = true
        fetchProductUseCase.execute(id: id) { [weak self] product in
            DispatchQueue.main.async {
                self?.product = product
                self?.isLoading = false
            }
        }
    }
}
