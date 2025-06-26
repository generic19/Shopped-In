//
//  CartRepositoryImplTest.swift
//  Shopped-In
//
//  Created by Omar Abdelaziz on 26/06/2025.
//

import Buy
@testable import Shopped_In
import XCTest

final class CartRepositoryImplTests: XCTestCase {
    var sut: CartRepositoryImpl!
    var mockRemote: MockCartRemoteDataSource!
    var mockLocal: MockCartSessionLocalDataSource!

    override func setUp() {
        super.setUp()
        mockRemote = MockCartRemoteDataSource()
        mockLocal = MockCartSessionLocalDataSource()
        sut = CartRepositoryImpl(remote: mockRemote, local: mockLocal)
    }

    override func tearDown() {
        sut = nil
        mockRemote = nil
        mockLocal = nil
        super.tearDown()
    }

//    func testCreateCart_ShouldStoreCartId_WhenSuccess() {
//        let expectation = expectation(description: "Cart creation")
//
//        sut.createCart(variantId: "v123", quantity: 1) { _ in
//            XCTAssertEqual(self.mockLocal.cartId, "mock_cart_id")
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 5)
//    }

    func testAddItem_ShouldCreateCart_WhenCartIdIsNil() {
        let expectation = expectation(description: "Add item triggers cart creation")

        mockLocal.cartId = nil
        sut.addItem(variantId: "v456", quantity: 2) { _ in
            XCTAssertEqual(self.mockLocal.cartId, "mock_cart_id")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testDeleteCart_ShouldClearLocalCartId() {
        mockLocal.cartId = "some_id"
        sut.deleteCart()
        XCTAssertNil(mockLocal.cartId)
        XCTAssertTrue(mockLocal.didCallClear)
    }

    func testFetchCart_ShouldReturnFailure_WhenRemoteFails() {
        mockRemote.shouldFailFetchCart = true
        let expectation = expectation(description: "Should return failure")

        sut.fetchCart { result in
            switch result {
            case .failure:
                XCTAssertTrue(true)
            case .success:
                XCTFail("Expected failure but got success")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
}

class MockCartRemoteDataSource: CartRemoteDataSource {
    var createdCartId: String?
    var shouldReturnError = false
    var shouldFailFetchCart = false
    var mockCart: Storefront.Cart?

    func createCart(variantId: String, quantity: Int, completion: @escaping (CartCreationResponse) -> Void) {
        if shouldReturnError {
            completion(.failure(NSError(domain: "test", code: 1)))
        } else {
            createdCartId = "mock_cart_id"
            completion(.success(cartId: "mock_cart_id"))
        }
    }

    func fetchCart(by id: String, completion: @escaping (Result<Storefront.Cart, Error>) -> Void) {
        if shouldFailFetchCart {
            completion(.failure(NSError(domain: "MockCartError", code: -1)))
        } else if let cart = mockCart {
            completion(.success(cart))
        }
    }

    func addItem(to cartId: String, variantId: String, quantity: Int, completion: @escaping (CartOperationResponse) -> Void) {
        completion(.success)
    }

    func updateItemQuantity(cartId: String, lineItemId: String, quantity: Int, completion: @escaping (CartOperationResponse) -> Void) {
        completion(.success)
    }

    func removeItem(cartId: String, lineItemId: String, completion: @escaping (CartOperationResponse) -> Void) {
        completion(.success)
    }

    func addDiscountCode(cartId: String, code: String, completion: @escaping (CartOperationResponse) -> Void) {
        completion(.success)
    }
}

class MockCartSessionLocalDataSource: CartSessionLocalDataSource {
    var cartId: String?
    var didCallClear = false

    func clear() {
        didCallClear = true
        cartId = nil
    }
}
