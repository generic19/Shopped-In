//
//  CartViewModelTest.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 26/06/2025.
//
import XCTest
@testable import Shopped_In

fileprivate class StubGetCartItemsUseCase: GetCartItemsUseCase {
    private(set) var executeCalled = false
    func execute(completion: @escaping (Result<Cart, Error>) -> Void) {
        executeCalled = true
    }
}

fileprivate class StubCreateCartUseCase: CreateCartUseCase {
    private(set) var executeCalled = false
    func execute(variantId: String, quantity: Int, completion: @escaping (CartOperationResponse) -> Void) {
        executeCalled = true
    }
}

fileprivate class StubDeleteCartUseCase: DeleteCartUseCase {
    private(set) var executeCalled = false
    func execute() {
        executeCalled = true
    }
}

fileprivate class StubAddToCartUseCase: AddToCartUseCase {
    private(set) var executeCalled = false
    var response: CartOperationResponse? = nil
    
    func execute(variantId: String, quantity: Int, completion: @escaping (CartOperationResponse) -> Void) {
        executeCalled = true
        
        if let response {
            completion(response)
        }
    }
}

fileprivate class StubRemoveFromCartUseCase: RemoveFromCartUseCase {
    private(set) var executeCalled = false
    func execute(lineItemId: String, completion: @escaping (CartOperationResponse) -> Void) {
        executeCalled = true
    }
}

fileprivate class StubUpdateCartItemQuantityUseCase: UpdateCartItemQuantityUseCase {
    private(set) var executeCalled = false
    func execute(lineItemId: String, quantity: Int, completion: @escaping (CartOperationResponse) -> Void) {
        executeCalled = true
    }
}

fileprivate class StubSetDiscountCodeUseCase: SetDiscountCodeUseCase {
    private(set) var executeCalled = false
    func execute(code: String, completion: @escaping (CartOperationResponse) -> Void) {
        executeCalled = true
    }
}

final class CartViewModelTests: XCTestCase {
    fileprivate var getCartItemsUC: StubGetCartItemsUseCase!
    fileprivate var createCartUC: StubCreateCartUseCase!
    fileprivate var deleteCartUC: StubDeleteCartUseCase!
    fileprivate var addToCartUC: StubAddToCartUseCase!
    fileprivate var removeFromCartUC: StubRemoveFromCartUseCase!
    fileprivate var updateQuantityUC: StubUpdateCartItemQuantityUseCase!
    fileprivate var setDiscountUC: StubSetDiscountCodeUseCase!
    
    var viewModel: CartViewModel!
    
    override func setUp() {
        super.setUp()
        getCartItemsUC = StubGetCartItemsUseCase()
        createCartUC = StubCreateCartUseCase()
        deleteCartUC = StubDeleteCartUseCase()
        addToCartUC = StubAddToCartUseCase()
        removeFromCartUC = StubRemoveFromCartUseCase()
        updateQuantityUC = StubUpdateCartItemQuantityUseCase()
        setDiscountUC = StubSetDiscountCodeUseCase()
        
        viewModel = CartViewModel(
            getCartItemsUseCase: getCartItemsUC,
            createCartUseCase: createCartUC,
            deleteCartUseCase: deleteCartUC,
            addToCartUseCase: addToCartUC,
            removeFromCartUseCase: removeFromCartUC,
            updateCartItemQuantityUseCase: updateQuantityUC,
            setDiscountCodeUseCase: setDiscountUC
        )
    }
    
    func test_loadCart_callsGetCartItemsUseCase() {
        viewModel.loadCart()
        XCTAssertTrue(getCartItemsUC.executeCalled, "loadCart() should call GetCartItemsUseCase.execute()")
    }
    
    func test_createCart_callsCreateCartUseCase() {
        addToCartUC.response = .failure(TestError.sampleError)
        viewModel.addToCart(variantId: "5", quantity: 1)
        XCTAssertTrue(createCartUC.executeCalled, "addToCart(...) without a cart should trigger CreateCartUseCase.execute()")
    }
    
    func test_addToCart_callsAddToCartUseCase() {
        viewModel.addToCart(variantId: "2", quantity: 3)
        XCTAssertTrue(addToCartUC.executeCalled, "addToCart(...) should call AddToCartUseCase.execute()")
    }
    
    func test_removeItem_callsRemoveFromCartUseCase() {
        viewModel.removeItem(lineItemId: "item123")
        XCTAssertTrue(removeFromCartUC.executeCalled, "removeItem(...) should call RemoveFromCartUseCase.execute()")
    }
    
    func test_updateQuantity_viaOnAddQuantityTapped_callsUpdateCartItemQuantityUseCase() {
        let fakeItem = CartItem(
            id: "item1",
            title: "Test Product",
            variantTitle: "Default Variant",
            quantity: 1,
            price: 10.0,
            imageURL: nil,
            variantId: "variant1",
            totalQuantity: 5
        )
        
        viewModel.cart = Cart(
            id: "cart1",
            items: [fakeItem],
            subtotal: fakeItem.price * Double(fakeItem.quantity),
            total: fakeItem.price * Double(fakeItem.quantity),
            discount: nil,
            totalQuantity: fakeItem.quantity
        )
        
        viewModel.onAddQuantityTapped(lineItemId: "item1")
        let newQuantity = viewModel.lineItemQuantities["item1"] ?? viewModel.cartItemFor(variantId: "variant1")?.quantity
        XCTAssertTrue(
            newQuantity == 2,
            "Expected quantity for variant to increase by 1."
        )
    }
    
    func test_removeDiscountCode_callsSetDiscountCodeUseCase() {
        viewModel.removeDiscountCode()
        XCTAssertTrue(setDiscountUC.executeCalled, "removeDiscountCode() should call SetDiscountCodeUseCase.execute()")
    }
    
    func test_applyDiscountCode_callsSetDiscountCodeUseCase() {
        viewModel.applyDiscountCode("SAVE20")
        XCTAssertTrue(setDiscountUC.executeCalled, "applyDiscountCode(...) should call SetDiscountCodeUseCase.execute()")
    }
}
