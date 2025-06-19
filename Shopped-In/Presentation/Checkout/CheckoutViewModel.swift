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
    
    private var user: User?
    private var customerAccessToken: String?
    
    let getAddressesUseCase = GetAddressesUseCase(repository: AddressRepositoryImpl(remote: AddressRemoteDataSourceImpl(service: BuyAPIService.shared)))
    
    let createOrderUseCase = CreateOrderUseCase(repository: OrderRepositoryImpl(remote: OrderRemoteDataSourceImpl(service: AlamofireAPIService.shared)))
    let getAllOrdersUseCase = GetAllOrdersUseCase(repository: OrderRepositoryImpl(remote: OrderRemoteDataSourceImpl(service: AlamofireAPIService.shared)))
    let getRecentOrdersUseCase = GetRecentOrdersUseCase(repository: OrderRepositoryImpl(remote: OrderRemoteDataSourceImpl(service: AlamofireAPIService.shared)))
                                                  
    //let getCustomerAccessTokenUseCase = GetCustomerAccessTokenUseCase(repository: TokenRepoImpl())
    
    init() {
        $selectedAddress.combineLatest($selectedPaymentMethod) { selectedAddress, selectedPaymentMethod in
            return selectedAddress == nil || selectedPaymentMethod == nil
        }
        .assign(to: &$isCheckoutDisabled)
    }
    
    func load() {
        // customerAccessToken = getCustomerAccessTokenUseCase.execute()
        self.user = User(email: "basel.alasadi@gmail.com", phone: "+201069696603", firstName: "Basel", lastName: "Alasase", customerID: "gid://shopify/Customer/7379231866916")
        self.customerAccessToken = "a83333ba147c99f3b004922d371d85df"
        
        if let customerAccessToken {
            loadCartItems()
            loadAddresses()
        } else {
            errorMessage = "Customer not signed in."
        }
    }
    
    func loadCartItems() {
        guard let customerAccessToken else {
            errorMessage = "User is not signed in."
            return
        }
        
        loadingMessage = "Loading cart for checkout..."
        
        DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(1))) { [weak self] in
            guard let self = self else { return }
            
            if DEBUG_IS_HAPPY_SCENARIO {
                self.loadingMessage = nil
                let cartItems = [
                    CartItem(id: "1", title: "Cart Item 1", quantity: 5, price: 1100, imageURL: nil, variantId: "gid://shopify/ProductVariant/42322834030628", availableQuantity: 11),
                    CartItem(id: "2", title: "Cart Item 2", quantity: 4, price: 1200, imageURL: nil, variantId: "gid://shopify/ProductVariant/42322834161700", availableQuantity: 12),
                    CartItem(id: "3", title: "Cart Item 3", quantity: 3, price: 1300, imageURL: nil, variantId: "gid://shopify/ProductVariant/42322834194468", availableQuantity: 13),
                    CartItem(id: "4", title: "Cart Item 4", quantity: 2, price: 1400, imageURL: nil, variantId: "gid://shopify/ProductVariant/42322834423844", availableQuantity: 14),
                    CartItem(id: "5", title: "Cart Item 5", quantity: 1, price: 1500, imageURL: nil, variantId: "gid://shopify/ProductVariant/42322835079204", availableQuantity: 15),
                ]
                self.cart = Cart(items: cartItems, subtotal: 2500, discountAmount: 110, total: 2390)
            } else {
                errorMessage = "Could not load cart items."
            }
        }
    }
    
    func loadAddresses() {
        guard let customerAccessToken else {
            errorMessage = "User is not signed in."
            return
        }
        
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
        guard let customerAccessToken, let user else {
            errorMessage = "User is not signed in."
            return
        }
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
            discountCode: nil,
            fixedDiscount: nil,
            fractionalDiscount: nil
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
