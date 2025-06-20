
import Combine
import Foundation

class CartViewModel: ObservableObject {
    @Published var cart: Cart?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var toastMessage = ""
    @Published var lineItemQuantities: [String: Int] = [:]
    @Published var discountCode: String = ""
    @Published var discountFeedback: String = ""
    @Published var showCheckout = false
    
    static let noProductsAddedErrorMsg = "No products added yet. Start shopping and add product items."
    
    private let getCartItemsUseCase: GetCartItemsUseCase
    private let createCartUseCase: CreateCartUseCase
    private let deleteCartUseCase: DeleteCartUseCase
    private let addToCartUseCase: AddToCartUseCase
    private let removeFromCartUseCase: RemoveFromCartUseCase
    private let updateCartItemQuantityUseCase: UpdateCartItemQuantityUseCase
    private let setDiscountCodeUseCase: SetDiscountCodeUseCase
    
    private var cancellable: Set<AnyCancellable> = []
    
    init(getCartItemsUseCase: GetCartItemsUseCase, createCartUseCase: CreateCartUseCase, deleteCartUseCase: DeleteCartUseCase, addToCartUseCase: AddToCartUseCase, removeFromCartUseCase: RemoveFromCartUseCase, updateCartItemQuantityUseCase: UpdateCartItemQuantityUseCase, setDiscountCodeUseCase: SetDiscountCodeUseCase) {
        self.getCartItemsUseCase = getCartItemsUseCase
        self.createCartUseCase = createCartUseCase
        self.deleteCartUseCase = deleteCartUseCase
        self.addToCartUseCase = addToCartUseCase
        self.removeFromCartUseCase = removeFromCartUseCase
        self.updateCartItemQuantityUseCase = updateCartItemQuantityUseCase
        self.setDiscountCodeUseCase = setDiscountCodeUseCase
        
        $lineItemQuantities
            .throttle(for: .milliseconds(200), scheduler: DispatchQueue.main, latest: true)
            .sink { [weak self] updatedQuantities in
                guard let self = self, let cart = self.cart else { return }
                
                for (lineItemId, quantity) in updatedQuantities {
                    if let item = cart.items.first(where: { $0.id == lineItemId }), item.quantity != quantity {
                        self.updateQuantity(lineItemId: lineItemId, quantity: quantity)
                    }
                }
            }
            .store(in: &cancellable)
    }
    
    func loadCart() {
        isLoading = true
        
        getCartItemsUseCase.execute() { [weak self] result in
            self?.isLoading = false
            switch result {
                case let .success(cart):
                    self?.cart = cart
                    if cart.discount?.isApplicable == true {
                        self?.discountCode = cart.discount?.code ?? ""
                    }
                case .failure:
                    self?.deleteCartUseCase.execute()
                    self?.cart = nil
                    self?.errorMessage = CartViewModel.noProductsAddedErrorMsg
            }
        }
    }
    
    func addToCart(variantId: String, quantity: Int) {
        print("from view Model variant is: \(variantId), and quantity is : \(quantity)")
        addToCartUseCase.execute(variantId: variantId, quantity: quantity) { [weak self] response in
            if case .failure = response {
                print("add to cart failure")
                self?.deleteCartUseCase.execute()
                self?.createCart(variantId: variantId, quantity: quantity)
            } else {
                print("add to cart success or error message")
                self?.handleResponse(response)
            }
        }
    }
    
    private func createCart(variantId: String, quantity: Int) {
        createCartUseCase.execute(variantId: variantId, quantity: quantity) { [weak self] response in
            if case .success = response {
                self?.loadCart()
            } else {
                self?.handleResponse(response)
            }
        }
    }
    
    private func updateQuantity(lineItemId: String, quantity: Int) {
        updateCartItemQuantityUseCase.execute(lineItemId: lineItemId, quantity: quantity) { [weak self] response in
            self?.handleResponse(response)
        }
    }
    
    func removeItem(lineItemId: String) {
        removeFromCartUseCase.execute(lineItemId: lineItemId) { [weak self] response in
            self?.handleResponse(response)
        }
    }
    
    private func handleResponse(_ response: CartOperationResponse) {
        switch response {
            case .success:
                loadCart()
            case let .failure(error):
                errorMessage = error.localizedDescription
            case let .errorMessage(msg):
                errorMessage = msg
        }
    }
    
    func onAddQuantityTapped(lineItemId: String) {
        guard let item = cart?.items.first(where: { $0.id == lineItemId }) else { return }
        let current = lineItemQuantities[lineItemId] ?? item.quantity
        if current < item.availableQuantity {
            lineItemQuantities[lineItemId] = current + 1
        }
    }
    
    func onMinusQuantityTapped(lineItemId: String) {
        guard let item = cart?.items.first(where: { $0.id == lineItemId }) else { return }
        let current = lineItemQuantities[lineItemId] ?? item.quantity
        if current > 1 {
            lineItemQuantities[lineItemId] = current - 1
        }
    }
    
    func applyDiscountCode(_ code: String) {
        setDiscountCodeUseCase.execute(code: code) { [weak self] response in
            let tempDiscountCode = self?.discountCode
            switch response {
                case .success:
                    self?.discountFeedback = ""
                    self?.loadCart()
                case let .errorMessage(err):
                    self?.removeDiscountCode {
                        self?.discountFeedback = err
                        self?.discountCode = tempDiscountCode ?? ""
                    }
                default:
                    self?.handleResponse(response)
            }
        }
    }
    
    func removeDiscountCode(completion: (() -> Void)? = nil) {
        setDiscountCodeUseCase.execute(code: "") { [weak self] response in
            switch response {
                case .errorMessage:
                    self?.discountFeedback = ""
                    self?.discountCode = ""
                    self?.loadCart()
                default:
                    self?.handleResponse(response)
            }
            completion?()
        }
    }
    
    func proceedToCheckout() {
        showCheckout = true
    }
}
