//
//  CheckoutViewModelTest.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 26/06/2025.
//
import XCTest
import Combine
import PassKit
@testable import Shopped_In

fileprivate class StubGetCustomerAccessTokenUseCase: GetCustomerAccessTokenUseCase {
    private let token: String?
    init(token: String?) { self.token = token }
    func execute() -> String? { token }
}

fileprivate class StubGetCurrentUserUseCase: GetCurrentUserUseCase {
    let subject: CurrentValueSubject<User?, Never>
    
    init(currentUser: User?) {
        self.subject = .init(currentUser)
    }
    
    func execute() -> AnyPublisher<User?, Never> {
        subject.eraseToAnyPublisher()
    }
}

fileprivate class StubGetCartItemsUseCase: GetCartItemsUseCase {
    private let result: Result<Cart, Error>
    private(set) var executeCalled = false

    init(result: Result<Cart, Error>) { self.result = result }
    func execute(completion: @escaping (Result<Cart, Error>) -> Void) {
        executeCalled = true
        completion(result)
    }
}

fileprivate class StubGetAddressesUseCase: GetAddressesUseCase {
    private let response: AddressResponse
    private(set) var receivedToken: String?
    init(response: AddressResponse) { self.response = response }
    func execute(
        customerAccessToken: String,
        completion: @escaping (AddressResponse) -> Void
    ) {
        receivedToken = customerAccessToken
        completion(response)
    }
}

fileprivate class StubDeleteCartUseCase: DeleteCartUseCase {
    private(set) var executeCalled = false
    func execute() { executeCalled = true }
}

fileprivate class StubCreateOrderUseCase: CreateOrderUseCase {
    func execute(
        cart: Cart,
        user: User,
        address: Address,
        discountCode: String?,
        fixedDiscount: Double?,
        fractionalDiscount: Double?,
        completion: @escaping (CreateOrderResult) -> Void
    ) {}
}

fileprivate class StubResendVerificationEmailUseCase: ResendVerificationEmailUseCase {
    private(set) var executeCalled = false
    func execute() { executeCalled = true }
}

fileprivate class StubReloadUserUseCase: ReloadUserUseCase {
    private(set) var executeCalled = false
    func execute() { executeCalled = true }
}

final class CheckoutViewModelTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func testLoad_whenNotSignedIn_setsErrorMessage() {
        let getCurrentUserUseCase = StubGetCurrentUserUseCase(currentUser: nil)
        
        let vm = CheckoutViewModel(
            getCartItemsUseCase: StubGetCartItemsUseCase(result: .failure(NSError())),
            getCustomerAccessTokenUseCase: StubGetCustomerAccessTokenUseCase(token: nil),
            getCurrentUserUseCase: getCurrentUserUseCase,
            getAddressesUseCase: StubGetAddressesUseCase(response: .error("")),
            createOrderUseCase: StubCreateOrderUseCase(),
            resendVerificationEmailUseCase: StubResendVerificationEmailUseCase(),
            reloadUserUseCase: StubReloadUserUseCase(),
            deleteCartUseCase: StubDeleteCartUseCase()
        )

        XCTAssertEqual(
            vm.errorMessage,
            "You must be signed in to checkout an order."
        )
    }

    func testLoad_whenUnverifiedUser_setsErrorMessageAndActions() {
        let tokenStub = StubGetCustomerAccessTokenUseCase(token: "token123")
        let user = User(
            email: "b@b.com", phone: nil,
            firstName: "Bob", lastName: "Builder",
            customerID: "id", isVerified: false
        )
        let userStub = StubGetCurrentUserUseCase(currentUser: user)
        let vm = CheckoutViewModel(
            getCartItemsUseCase: StubGetCartItemsUseCase(result: .failure(NSError())),
            getCustomerAccessTokenUseCase: tokenStub,
            getCurrentUserUseCase: userStub,
            getAddressesUseCase: StubGetAddressesUseCase(response: .error("")),
            createOrderUseCase: StubCreateOrderUseCase(),
            resendVerificationEmailUseCase: StubResendVerificationEmailUseCase(),
            reloadUserUseCase: StubReloadUserUseCase(),
            deleteCartUseCase: StubDeleteCartUseCase()
        )

        XCTAssertEqual(
            vm.errorMessage,
            "Email verification is required to proceed with checkout."
        )
        XCTAssertEqual(vm.errorActions?.count, 2)
        XCTAssertEqual(vm.errorActions?.first?.title, "Re-send Email")
    }

    func testLoad_verifiedUser_publishesCartAndAddresses() {
        let tokenStub = StubGetCustomerAccessTokenUseCase(token: "tok")
        let user = User(
            email: "b@b.com", phone: nil,
            firstName: "Bob", lastName: "Builder",
            customerID: "id", isVerified: true
        )
        let userStub = StubGetCurrentUserUseCase(currentUser: user)
        let dummyCart = Cart(
            id: "c1", items: [], subtotal: 0, total: 0,
            discount: nil, totalQuantity: 0
        )
        let cartStub = StubGetCartItemsUseCase(result: .success(dummyCart))

        let address = Address(
            id: "a1", name: "Home",
            address1: "1 St", address2: nil,
            city: "Cairo", country: "EG",
            phone: "123"
        )
        let addrStub = StubGetAddressesUseCase(
            response: .success(addresses: [address], defaultAddress: address)
        )

        let vm = CheckoutViewModel(
            getCartItemsUseCase: cartStub,
            getCustomerAccessTokenUseCase: tokenStub,
            getCurrentUserUseCase: userStub,
            getAddressesUseCase: addrStub,
            createOrderUseCase: StubCreateOrderUseCase(),
            resendVerificationEmailUseCase: StubResendVerificationEmailUseCase(),
            reloadUserUseCase: StubReloadUserUseCase(),
            deleteCartUseCase: StubDeleteCartUseCase()
        )

        let cartExp = expectation(description: "cart set")
        cartExp.assertForOverFulfill = false
        vm.$cart
          .compactMap { $0 }
          .sink { c in
              XCTAssertEqual(c.id, "c1")
              cartExp.fulfill()
          }
          .store(in: &cancellables)

        let addrExp = expectation(description: "addresses set")
        addrExp.assertForOverFulfill = false
        vm.$addresses
          .compactMap { $0 }
          .sink { addrs in
              XCTAssertEqual(addrs.first?.id, "a1")
              addrExp.fulfill()
          }
          .store(in: &cancellables)
        
        vm.load()

        wait(for: [cartExp, addrExp], timeout: 1.0)
        XCTAssertTrue(cartStub.executeCalled)
        XCTAssertEqual(addrStub.receivedToken, "tok")
    }

    func testClearCart_callsDeleteCartUseCase() {
        let deleteStub = StubDeleteCartUseCase()
        let user = User(
            email: "b@b.com", phone: nil,
            firstName: "Bob", lastName: "Builder",
            customerID: "id", isVerified: false
        )
        let vm = CheckoutViewModel(
            getCartItemsUseCase: StubGetCartItemsUseCase(result: .failure(NSError())),
            getCustomerAccessTokenUseCase: StubGetCustomerAccessTokenUseCase(token: nil),
            getCurrentUserUseCase: StubGetCurrentUserUseCase(currentUser: user),
            getAddressesUseCase: StubGetAddressesUseCase(response: .error("")),
            createOrderUseCase: StubCreateOrderUseCase(),
            resendVerificationEmailUseCase: StubResendVerificationEmailUseCase(),
            reloadUserUseCase: StubReloadUserUseCase(),
            deleteCartUseCase: deleteStub
        )

        vm.clearCart()

        XCTAssertTrue(deleteStub.executeCalled)
    }
}
