import Combine
import Foundation

class CheckoutViewModel: ObservableObject {
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
    @Published var isCheckoutSuccessful: Bool?
    
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
    
    init(getCartItemsUseCase: GetCartItemsUseCase, getCustomerAccessTokenUseCase: GetCustomerAccessTokenUseCase, getCurrentUserUseCase: GetCurrentUserUseCase, getAddressesUseCase: GetAddressesUseCase, createOrderUseCase: CreateOrderUseCase, resendVerificationEmailUseCase: ResendVerificationEmailUseCase, reloadUserUseCase: ReloadUserUseCase) {
        self.getCartItemsUseCase = getCartItemsUseCase
        self.getCustomerAccessTokenUseCase = getCustomerAccessTokenUseCase
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.getAddressesUseCase = getAddressesUseCase
        self.createOrderUseCase = createOrderUseCase
        self.resendVerificationEmailUseCase = resendVerificationEmailUseCase
        self.reloadUserUseCase = reloadUserUseCase
        
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
    
    func completeCheckout() {
        if let customerAccessToken, let user {
            completeCheckout(customerAccessToken: customerAccessToken, user: user)
        }
    }
    
    private func completeCheckout(customerAccessToken: String, user: User) {
        guard let cart else {
            errorMessage = "No cart to process."
            return
        }
        guard let selectedAddress else {
            errorMessage = "No selected shipping address."
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
            self.loadingMessage = nil
            
            switch result {
                case .success(let order):
                    self.errorMessage = nil
                    print("order success: \(order)")
                    
                case .error(let message):
                    self.errorMessage = message
            }
        }
    }
}
