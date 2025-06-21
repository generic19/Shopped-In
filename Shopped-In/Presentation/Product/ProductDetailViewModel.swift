import Foundation
import Combine
import FirebaseAuth

class ProductDetailViewModel: ObservableObject {
    @Published var product: Product?
    @Published var isLoading = false
    @Published var isFavorite = false
    @Published var selectedSize: String?
    @Published var selectedColor: String?
    @Published var selectedVariantId: String?
    
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
        
        fetchProductUseCase.execute(id: id) { [weak self] fetchedProduct in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.product = fetchedProduct
                self.isLoading = false

                guard let productID = fetchedProduct?.title else {
                    self.isFavorite = false
                    return
                }

                self.checkFavoriteUseCase.execute(productID: productID) { isFav in
                    DispatchQueue.main.async {
                        self.isFavorite = isFav
                    }
                }
            }
        }
    }

    func toggleFavorite() {
        guard let product = product else { return }
        let productID = product.title

        if isFavorite {
            removeFavoriteUseCase.execute(productID: productID) { [weak self] error in
                DispatchQueue.main.async {
                    if error == nil {
                        self?.isFavorite = false
                    }
                }
            }
        } else {
            addFavoriteUseCase.execute(product: product) { [weak self] error in
                DispatchQueue.main.async {
                    if error == nil {
                        self?.isFavorite = true
                    }
                }
            }
        }
    }
    
    func updateSelectedVariant() {
        guard let product = product,
              let size = selectedSize,
              let color = selectedColor else {
            selectedVariantId = nil
            return
        }

        for variant in product.variants {
            print("Looping variant: \(variant.id)")

            if let variantSize = variant.selectedOptions["size"],
               let variantColor = variant.selectedOptions["color"] {
                
                print("variantSize: \(variantSize), variantColor: \(variantColor)")
                print("Comparing with selected size: \(size), selected color (name): \(color)")

                if variantSize.lowercased() == size.lowercased(),
                   variantColor.lowercased() == color.lowercased() {
                    selectedVariantId = variant.id
                    print("Selected Variant ID: \(variant.id)")
                    return
                } else {
                    print("Mismatch: variant doesn't match selected options")
                }
            } else {
                print(" Missing keys: size or color not found in selectedOptions -> \(variant.selectedOptions)")
            }
        }

        selectedVariantId = nil
        print("No matching variant found")
    }

}

