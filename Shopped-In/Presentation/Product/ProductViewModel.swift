import Foundation

class ProductDetailViewModel: ObservableObject {
    @Published var product: Product?
    @Published var isLoading = false
    @Published var selectedSize: String?
    @Published var selectedColor: String?
    @Published var selectedVariantId: String?
    
    
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
