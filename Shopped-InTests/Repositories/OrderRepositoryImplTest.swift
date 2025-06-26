//
//  OrderRepositoryImplTest.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 26/06/2025.
//
import XCTest
import Alamofire
@testable import Shopped_In

fileprivate class MockOrderRemoteDataSource: OrderRemoteDataSource {
    private(set) var createOrderCalled = false
    private(set) var createOrderCart: Cart?
    private(set) var createOrderUser: User?
    private(set) var createOrderAddress: Address?
    private(set) var createOrderDiscountCode: String?
    private(set) var createOrderFixedDiscount: Double?
    private(set) var createOrderFractionalDiscount: Double?
    var createOrderResultToReturn: Result<Order, OrderError>?

    private(set) var getAllOrdersCalled = false
    private(set) var getAllOrdersCustomerID: String?
    var getAllOrdersResultToReturn: Result<[Order], OrderError>?

    private(set) var getRecentOrdersCalled = false
    private(set) var getRecentOrdersCustomerID: String?
    var getRecentOrdersResultToReturn: Result<[Order], OrderError>?

    func createOrder(
        cart: Cart,
        user: User,
        address: Address,
        discountCode: String?,
        fixedDiscount: Double?,
        fractionalDiscount: Double?,
        completion: @escaping (Result<Order, OrderError>) -> Void
    ) {
        createOrderCalled = true
        createOrderCart = cart
        createOrderUser = user
        createOrderAddress = address
        createOrderDiscountCode = discountCode
        createOrderFixedDiscount = fixedDiscount
        createOrderFractionalDiscount = fractionalDiscount
        if let result = createOrderResultToReturn {
            completion(result)
        }
    }

    func getAllOrders(
        customerID: String,
        completion: @escaping (Result<[Order], OrderError>) -> Void
    ) {
        getAllOrdersCalled = true
        getAllOrdersCustomerID = customerID
        if let result = getAllOrdersResultToReturn {
            completion(result)
        }
    }

    func getRecentOrders(
        customerID: String,
        completion: @escaping (Result<[Order], OrderError>) -> Void
    ) {
        getRecentOrdersCalled = true
        getRecentOrdersCustomerID = customerID
        if let result = getRecentOrdersResultToReturn {
            completion(result)
        }
    }
}

final class OrderRepositoryImplTests: XCTestCase {
    private var mockRemote: MockOrderRemoteDataSource!
    private var repository: OrderRepositoryImpl!

    override func setUp() {
        super.setUp()
        mockRemote = MockOrderRemoteDataSource()
        repository = OrderRepositoryImpl(remote: mockRemote)
    }

    override func tearDown() {
        repository = nil
        mockRemote = nil
        super.tearDown()
    }

    func testCreateOrderSuccess() {
        let testCart = Cart(id: "cart1", items: [], subtotal: 0, total: 0, discount: nil, totalQuantity: 0)
        let testUser = User(email: "test@example.com", phone: nil, firstName: "Test", lastName: "User", customerID: "cust123")
        let testAddress = Address(id: "addr1", name: "Home", address1: "123 Main St", address2: nil, city: "Cairo", country: "Egypt", phone: "0123456")
        let expectedOrder = Order(
            id: "order1",
            items: [],
            discountCodes: [],
            subtotal: Amount(value: 0, currency: .EGP),
            discount: Amount(value: 0, currency: .EGP),
            total: Amount(value: 0, currency: .EGP)
        )
        mockRemote.createOrderResultToReturn = .success(expectedOrder)

        let exp = expectation(description: "createOrder completion")
        var receivedResult: CreateOrderResult?

        repository.createOrder(
            cart: testCart,
            user: testUser,
            address: testAddress,
            discountCode: "DISCOUNT",
            fixedDiscount: 5.0,
            fractionalDiscount: 0.1
        ) { result in
            receivedResult = result
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)

        XCTAssertTrue(mockRemote.createOrderCalled)
        XCTAssertEqual(mockRemote.createOrderCart?.id, testCart.id)
        XCTAssertEqual(mockRemote.createOrderUser?.email, testUser.email)
        XCTAssertEqual(mockRemote.createOrderAddress?.id, testAddress.id)
        XCTAssertEqual(mockRemote.createOrderDiscountCode, "DISCOUNT")
        XCTAssertEqual(mockRemote.createOrderFixedDiscount, 5.0)
        XCTAssertEqual(mockRemote.createOrderFractionalDiscount, 0.1)

        if case let .success(order) = receivedResult {
            XCTAssertEqual(order.id, expectedOrder.id)
        } else {
            XCTFail("Expected success with order, got \(String(describing: receivedResult))")
        }
    }

    func testCreateOrderFailure() {
        mockRemote.createOrderResultToReturn = .failure(.alamofireError(error: AFError.explicitlyCancelled))
        let exp = expectation(description: "createOrder failure completion")
        var receivedResult: CreateOrderResult?

        repository.createOrder(
            cart: Cart(id: "c", items: [], subtotal: 0, total: 0, discount: nil, totalQuantity: 0),
            user: User(email: "e", phone: nil, firstName: "F", lastName: "L", customerID: nil),
            address: Address(id: "a", name: "N", address1: "A", address2: nil, city: "City", country: "Country", phone: "P"),
            discountCode: nil,
            fixedDiscount: nil,
            fractionalDiscount: nil
        ) { result in
            receivedResult = result
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)

        if case let .error(message) = receivedResult {
            XCTAssertTrue(message.contains("Networking error"))
        } else {
            XCTFail("Expected error, got \(String(describing: receivedResult))")
        }
    }

    func testGetAllOrdersSuccess() {
        let orders = [Order(
            id: "o1",
            items: [],
            discountCodes: [],
            subtotal: Amount(value: 0, currency: .USD),
            discount: Amount(value: 0, currency: .USD),
            total: Amount(value: 0, currency: .USD)
        )]
        mockRemote.getAllOrdersResultToReturn = .success(orders)
        let exp = expectation(description: "getAllOrders completion")
        var receivedResult: GetOrdersResult?

        repository.getAllOrders(customerID: "cust123") { result in
            receivedResult = result
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)

        XCTAssertTrue(mockRemote.getAllOrdersCalled)
        XCTAssertEqual(mockRemote.getAllOrdersCustomerID, "cust123")

        if case let .success(returned) = receivedResult {
            XCTAssertEqual(returned.count, 1)
            XCTAssertEqual(returned.first?.id, "o1")
        } else {
            XCTFail("Expected success with orders, got \(String(describing: receivedResult))")
        }
    }

    func testGetAllOrdersFailure() {
        mockRemote.getAllOrdersResultToReturn = .failure(.alamofireError(error: AFError.invalidURL(url: "nil")))
        let exp = expectation(description: "getAllOrders failure")
        var receivedResult: GetOrdersResult?

        repository.getAllOrders(customerID: "") { result in
            receivedResult = result
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)

        if case let .error(message) = receivedResult {
            XCTAssertTrue(message.contains("Networking error"))
        } else {
            XCTFail("Expected error, got \(String(describing: receivedResult))")
        }
    }

    func testGetRecentOrdersSuccess() {
        let orders = [Order(
            id: "o2",
            items: [],
            discountCodes: [],
            subtotal: Amount(value: 0, currency: .USD),
            discount: Amount(value: 0, currency: .USD),
            total: Amount(value: 0, currency: .USD)
        )]
        mockRemote.getRecentOrdersResultToReturn = .success(orders)
        let exp = expectation(description: "getRecentOrders completion")
        var receivedResult: GetOrdersResult?

        repository.getRecentOrders(customerID: "cust456") { result in
            receivedResult = result
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)

        XCTAssertTrue(mockRemote.getRecentOrdersCalled)
        XCTAssertEqual(mockRemote.getRecentOrdersCustomerID, "cust456")

        if case let .success(returned) = receivedResult {
            XCTAssertEqual(returned.first?.id, "o2")
        } else {
            XCTFail("Expected success with recent orders, got \(String(describing: receivedResult))")
        }
    }

    func testGetRecentOrdersFailure() {
        mockRemote.getRecentOrdersResultToReturn = .failure(.alamofireError(error: AFError.responseValidationFailed(reason: AFError.ResponseValidationFailureReason.unacceptableStatusCode(code: 404))))
        let exp = expectation(description: "getRecentOrders failure")
        var receivedResult: GetOrdersResult?

        repository.getRecentOrders(customerID: "cust789") { result in
            receivedResult = result
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)

        if case let .error(message) = receivedResult {
            XCTAssertTrue(message.contains("Networking error"))
        } else {
            XCTFail("Expected error, got \(String(describing: receivedResult))")
        }
    }
}
