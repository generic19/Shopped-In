import Combine
import PassKit

private let COD_MAXIMUM = 10000.0

class CheckoutViewModel: NSObject, ObservableObject {
    struct ErrorAction {
        let title: String
        let action: () -> Void
    }
    
    @Published var loadingMessage: String?
    @Published var errorMessage: String?
    @Published var errorActions: [ErrorAction]?
    
    @Published var cart: Cart?
    
    @Published var addressesLoadingMessage: String?
    @Published var addresses: [Address]?
    @Published var selectedAddress: Address?
    
    @Published var selectedPaymentMethod: PaymentMethod?
    
    @Published var isCheckoutDisabled = true
    @Published var showCheckoutSuccess = false
    
    @Published var user: User?
    private var cancellables = Set<AnyCancellable>()
    private var customerAccessToken: String? { getCustomerAccessTokenUseCase.execute() }
    
    private let getCartItemsUseCase: GetCartItemsUseCase
    private let getCustomerAccessTokenUseCase: GetCustomerAccessTokenUseCase
    private let getCurrentUserUseCase: GetCurrentUserUseCase
    private let getAddressesUseCase: GetAddressesUseCase
    private let createOrderUseCase: CreateOrderUseCase
    private let resendVerificationEmailUseCase: ResendVerificationEmailUseCase
    private let reloadUserUseCase: ReloadUserUseCase
    private let deleteCartUseCase: DeleteCartUseCase
    
    init(getCartItemsUseCase: GetCartItemsUseCase, getCustomerAccessTokenUseCase: GetCustomerAccessTokenUseCase, getCurrentUserUseCase: GetCurrentUserUseCase, getAddressesUseCase: GetAddressesUseCase, createOrderUseCase: CreateOrderUseCase, resendVerificationEmailUseCase: ResendVerificationEmailUseCase, reloadUserUseCase: ReloadUserUseCase, deleteCartUseCase: DeleteCartUseCase) {
        self.getCartItemsUseCase = getCartItemsUseCase
        self.getCustomerAccessTokenUseCase = getCustomerAccessTokenUseCase
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.getAddressesUseCase = getAddressesUseCase
        self.createOrderUseCase = createOrderUseCase
        self.resendVerificationEmailUseCase = resendVerificationEmailUseCase
        self.reloadUserUseCase = reloadUserUseCase
        self.deleteCartUseCase = deleteCartUseCase
        
        super.init()
        
        getCurrentUserUseCase.execute().assign(to: &$user)
        $user.sink { _ in
            self.load()
        }.store(in: &cancellables)
        
        $selectedAddress.combineLatest($selectedPaymentMethod) { selectedAddress, selectedPaymentMethod in
            return selectedAddress == nil || selectedPaymentMethod == nil
        }
        .assign(to: &$isCheckoutDisabled)
    }
    
    func load() {
        guard let customerAccessToken, let user else {
            errorMessage = "You must be signed in to checkout an order."
            return
        }
        if !user.isVerified {
            errorMessage = "Email verification is required to proceed with checkout."
            errorActions = [
                ErrorAction(title: "Re-send Email", action: { [weak self] in
                    self?.resendVerificationEmailUseCase.execute()
                }),
                ErrorAction(title: "Check Again", action: { [weak self] in
                    self?.reloadUserUseCase.execute()
                }),
            ]
            return
        }
        
        loadCartItems(customerAccessToken: customerAccessToken)
        loadAddresses(customerAccessToken: customerAccessToken)
    }
}

// Cart Operations
extension CheckoutViewModel {
    private func loadCartItems(customerAccessToken: String) {
        cart = nil
        loadingMessage = "Loading cart for checkout..."
        
        getCartItemsUseCase.execute() { result in
            self.loadingMessage = nil
            
            switch result {
                case .success(let cart):
                    self.errorMessage = nil
                    self.cart = cart
                    
                case .failure(_):
                    self.errorMessage = "An error occured while loading your cart."
            }
        }
    }
    
    func clearCart() {
        self.deleteCartUseCase.execute()
    }
}

// Addresses Operations
extension CheckoutViewModel {
    func loadAddresses() {
        if let customerAccessToken {
            loadAddresses(customerAccessToken: customerAccessToken)
        }
    }
    
    private func loadAddresses(customerAccessToken: String) {
        addressesLoadingMessage = "Loading saved addresses..."

        getAddressesUseCase.execute(customerAccessToken: customerAccessToken) { [weak self] response in
            guard let self = self else { return }
            
            addressesLoadingMessage  = nil
            
            switch response {
                case .success(let addresses, let defaultAddress):
                    self.addresses = addresses
                    self.selectedAddress = defaultAddress
                    
                case .error(let message):
                    self.errorMessage = message
            }
        }
    }
}

// Apple Pay
extension CheckoutViewModel: PKPaymentAuthorizationControllerDelegate {
    func checkoutWithApplePay() {
        guard let cart, let customerAccessToken, let user else {
            return
        }
        
        let request = PKPaymentRequest()
        request.merchantIdentifier = "iti.mad45-sv.ios-team3.Shopped-In"
        request.countryCode = "EG"
        request.currencyCode = "EGP"
        request.supportedNetworks = [.visa, .masterCard, .meeza]
        request.merchantCapabilities = [.credit, .debit, .threeDSecure]
        
        var items = cart.items.map { item in
            var label = item.quantity != 1 ? "\(item.quantity)x" : ""
            label.append("\(item.title) (\(item.variantTitle))")
            
            let itemTotal = item.price * Double(item.quantity)
            
            return PKPaymentSummaryItem(label: label, amount: NSDecimalNumber(value: itemTotal), type: .final)
        }
        
        items.append(PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(value: cart.total), type: .final))
        request.paymentSummaryItems = items
        
        let paymentController = PKPaymentAuthorizationController(paymentRequest: request)
        paymentController.delegate = self
        paymentController.present(completion: nil)
    }
    
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        
        guard let customerAccessToken, let user else {
            completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
            return
        }
        
        completeCheckout(customerAccessToken: customerAccessToken, user: user) { isSuccess in
            completion(PKPaymentAuthorizationResult(status: isSuccess ? .success : .failure, errors: nil))
        }
    }
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss(completion: nil)
    }
}

// Checkout Operations
extension CheckoutViewModel {
    func completeCheckout() {
        if let customerAccessToken, let user {
            completeCheckout(customerAccessToken: customerAccessToken, user: user)
        } else {
            errorMessage = "You must be signed in to checkout an order."
        }
    }
    
    private func completeCheckout(customerAccessToken: String, user: User, onResultStatus: ((Bool) -> Void)? = nil) {
        guard let cart else {
            errorMessage = "No cart to process."
            return
        }
        guard let selectedAddress else {
            errorMessage = "No selected shipping address."
            return
        }
        
        if selectedPaymentMethod == .cashOnDelivery && cart.total > COD_MAXIMUM {
            onResultStatus?(false)
            
            errorMessage = String(format: "Cannot pay using cash on delivery for orders over EGP %.2f.", COD_MAXIMUM)
            errorActions = [
                ErrorAction(title: "Choose Payment Method", action: {
                    self.errorMessage = nil
                    self.errorActions = nil
                    self.selectedPaymentMethod = nil
                })
            ]
            
            return
        }
        
        loadingMessage = "Processing checkout request..."
        
        let fractionalDiscount: Double? = if let percentage = cart.discount?.percentage {
            percentage / 100
        } else { nil }
        
        createOrderUseCase.execute(
            cart: cart,
            user: user,
            address: selectedAddress,
            discountCode: cart.discount?.code,
            fixedDiscount: cart.discount?.fixedAmount,
            fractionalDiscount: fractionalDiscount,
        ) { result in
            switch result {
                case .success(_):
                    onResultStatus?(true)
                    
                    self.errorMessage = nil
                    self.showCheckoutSuccess = true
                    
                case .error(let message):
                    onResultStatus?(false)
                    
                    self.errorMessage = message
            }
            
            self.loadingMessage = nil
        }
    }
}
