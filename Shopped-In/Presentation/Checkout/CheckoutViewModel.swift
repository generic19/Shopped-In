import Combine
import Foundation

fileprivate let DEBUG_IS_HAPPY_SCENARIO = true

class CheckoutViewModel: ObservableObject {
    @Published var loadingMessage: String?
    @Published var errorMessage: String?
    
    @Published var cart: Cart?
    
    @Published var addressesLoadingMessage: String?
    @Published var addresses: [Address]?
    @Published var selectedAddress: Address?
    
    @Published var selectedPaymentMethod: PaymentMethod?
    
    @Published var isCheckoutDisabled = true
    @Published var isCheckoutSuccessful: Bool?
    
    @Published var user: User?
    
    private var customerAccessToken: String? { getCustomerAccessTokenUseCase.execute() }
    private var cartID: String? { getCartIDUseCase.execute() }
    
    private let getCartIDUseCase = GetCartIDUseCase()
    private let getCartItemsUseCase = GetCartItemsUseCaseImpl(repository: CartRepositoryImpl(remote: CartRemoteDataSourceImpl(service: BuyAPIService.shared)))
    private let getCustomerAccessTokenUseCase = GetCustomerAccessTokenUseCase(repository: TokenRepoImpl())
    private let getCurrentUserUseCase = GetCurrentUserUseCase(authRepository: AuthRepositoryImpl(tokenRepository: TokenRepoImpl(), apiSource: APIAuthRemoteDataSourceImpl(service: BuyAPIService.shared), firebaseSource: FireBaseAuthRemoteDataSourceImpl()))
    private let getAddressesUseCase = GetAddressesUseCase(repository: AddressRepositoryImpl(remote: AddressRemoteDataSourceImpl(service: BuyAPIService.shared)))
    private let createOrderUseCase = CreateOrderUseCase(repository: OrderRepositoryImpl(remote: OrderRemoteDataSourceImpl(service: AlamofireAPIService.shared)))

    init() {
        getCurrentUserUseCase.execute().assign(to: &$user)
        
        $selectedAddress.combineLatest($selectedPaymentMethod) { selectedAddress, selectedPaymentMethod in
            return selectedAddress == nil || selectedPaymentMethod == nil
        }
        .assign(to: &$isCheckoutDisabled)
    }
    
    func load() {
        guard let customerAccessToken, let user else {
            print(customerAccessToken)
            print(user)
            errorMessage = "You must be signed in to checkout an order."
            return
        }
        if !user.isVerified {
            errorMessage = "Email verification is required to proceed with checkout."
            return
        }
        guard let cartID else {
            errorMessage = "Your cart is empty."
            return
        }
        
        loadCartItems(customerAccessToken: customerAccessToken, cartID: cartID)
        loadAddresses(customerAccessToken: customerAccessToken)
    }
    
    private func loadCartItems(customerAccessToken: String, cartID: String) {
        cart = nil
        loadingMessage = "Loading cart for checkout..."
        
        getCartItemsUseCase.execute(cartId: cartID) { result in
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
        
        createOrderUseCase.execute(
            cart: cart,
            user: user,
            address: selectedAddress,
            discountCode: cart.discount?.code,
            fixedDiscount: cart.discount?.fixedAmount,
            fractionalDiscount: cart.discount?.percentage,
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
