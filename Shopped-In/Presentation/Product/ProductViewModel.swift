import Foundation
import Combine
import FirebaseAuth

class ProductDetailViewModel: ObservableObject {
    @Published var product: Product? = nil
    @Published var isLoading = false
    @Published var isFavorite = false
    
    private let fetchProductUseCase: FetchProductUseCase
    private let addFavoriteUseCase: AddFavoriteProductUseCase
    private let removeFavoriteUseCase: RemoveFavoriteProductUseCase
    private let checkFavoriteUseCase: CheckFavoriteProductUseCase

    private var cancellables = Set<AnyCancellable>()
    
    init(
        fetchProductUseCase: FetchProductUseCase,
        addFavoriteUseCase: AddFavoriteProductUseCase,
        removeFavoriteUseCase: RemoveFavoriteProductUseCase,
        checkFavoriteUseCase: CheckFavoriteProductUseCase
    ) {
        self.fetchProductUseCase = fetchProductUseCase
        self.addFavoriteUseCase = addFavoriteUseCase
        self.removeFavoriteUseCase = removeFavoriteUseCase
        self.checkFavoriteUseCase = checkFavoriteUseCase
    }
    
    func fetchProduct(by id: String) {
        isLoading = true
        fetchProductUseCase.execute(id: id) { [weak self] product in
            DispatchQueue.main.async {
                self?.product = product
                self?.isLoading = false
                // Check if product is favorite
                if let productID = product?.title {
                    self?.checkFavoriteUseCase.checkFavorite(productID: productID) { isFav in
                        DispatchQueue.main.async {
                            self?.isFavorite = isFav
                        }
                    }
                }
            }
        }
    }
    
    func toggleFavorite() {
        guard let product = product else { return }
        let productID = product.title
        
        if isFavorite {
            removeFavoriteUseCase.removeFavorite(productID: productID) { [weak self] error in
                DispatchQueue.main.async {
                    if error == nil {
                        self?.isFavorite = false
                    }
                }
            }
        } else {
            addFavoriteUseCase.addFavorite(product: product) { [weak self] error in
                DispatchQueue.main.async {
                    if error == nil {
                        self?.isFavorite = true
                    }
                }
            }
        }
    }
}
