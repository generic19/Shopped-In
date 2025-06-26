//
//  OrdersViewModelTest.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 26/06/2025.
//
import XCTest
import Combine
@testable import Shopped_In

fileprivate class StubGetCurrentUserUseCase: GetCurrentUserUseCase {
    private let subject: CurrentValueSubject<User?, Never>
    private(set) var executeCalled = false

    init(user: User?) {
        subject = CurrentValueSubject(user)
    }

    func execute() -> AnyPublisher<User?, Never> {
        executeCalled = true
        return subject.eraseToAnyPublisher()
    }
}

fileprivate class StubGetRecentOrdersUseCase: GetRecentOrdersUseCase {
    private(set) var executeCalled = false
    private(set) var capturedCustomerID: String?
    var completionHandler: ((GetOrdersResult) -> Void)?

    func execute(customerID: String, completion: @escaping (GetOrdersResult) -> Void) {
        executeCalled = true
        capturedCustomerID = customerID
        completionHandler = completion
    }
}

fileprivate class StubGetAllOrdersUseCase: GetAllOrdersUseCase {
    private(set) var executeCalled = false
    private(set) var capturedCustomerID: String?
    var completionHandler: ((GetOrdersResult) -> Void)?

    func execute(customerID: String, completion: @escaping (GetOrdersResult) -> Void) {
        executeCalled = true
        capturedCustomerID = customerID
        completionHandler = completion
    }
}

final class OrdersViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    func testInit_assignsCurrentUser() {
        let expectedUser = User(
            email: "test@example.com",
            phone: "1234567890",
            firstName: "First",
            lastName: "Last",
            customerID: "cust-123",
            isVerified: true
        )
        let stubUserUC = StubGetCurrentUserUseCase(user: expectedUser)
        let stubRecentUC = StubGetRecentOrdersUseCase()
        let stubAllUC = StubGetAllOrdersUseCase()

        let vm = OrdersViewModel(
            getAllOrdersUseCase: stubAllUC,
            getRecentOrdersUseCase: stubRecentUC,
            getCurrentUserUseCase: stubUserUC
        )

        XCTAssertTrue(stubUserUC.executeCalled, "Should call GetCurrentUserUseCase.execute() on init")
        XCTAssertEqual(vm.currentUser?.customerID, expectedUser.customerID)
    }

    func testLoadRecentOrders_success() {
        let user = User(
            email: "a@b.com",
            phone: nil,
            firstName: "A",
            lastName: "B",
            customerID: "user-1",
            isVerified: false
        )
        let stubUserUC = StubGetCurrentUserUseCase(user: user)
        let stubRecentUC = StubGetRecentOrdersUseCase()
        let stubAllUC = StubGetAllOrdersUseCase()
        let vm = OrdersViewModel(
            getAllOrdersUseCase: stubAllUC,
            getRecentOrdersUseCase: stubRecentUC,
            getCurrentUserUseCase: stubUserUC
        )

        vm.loadRecentOrders()

        XCTAssertTrue(stubRecentUC.executeCalled, "Should invoke GetRecentOrdersUseCase")
        XCTAssertEqual(stubRecentUC.capturedCustomerID, user.customerID)

        if case .loading = vm.recentOrdersState {
            // ok
        } else {
            XCTFail("Expected .loading state before completion")
        }

        let emptyOrders: [Order] = []
        stubRecentUC.completionHandler?(.success(emptyOrders))

        guard case .success(let orders) = vm.recentOrdersState else {
            return XCTFail("Expected .success state after completion")
        }
        XCTAssertEqual(orders.count, emptyOrders.count)
    }

    func testLoadRecentOrders_error() {
        let user = User(
            email: "x@y.com",
            phone: nil,
            firstName: "X",
            lastName: "Y",
            customerID: "user-2",
            isVerified: false
        )
        let stubUserUC = StubGetCurrentUserUseCase(user: user)
        let stubRecentUC = StubGetRecentOrdersUseCase()
        let stubAllUC = StubGetAllOrdersUseCase()
        let vm = OrdersViewModel(
            getAllOrdersUseCase: stubAllUC,
            getRecentOrdersUseCase: stubRecentUC,
            getCurrentUserUseCase: stubUserUC
        )

        vm.loadRecentOrders()

        stubRecentUC.completionHandler?(.error("Network error"))

        guard case .failure(let message) = vm.recentOrdersState else {
            return XCTFail("Expected .failure state on error")
        }
        XCTAssertEqual(message, "Network error")
    }

    func testLoadAllOrders_success() {
        let user = User(
            email: "u@v.com",
            phone: "000",
            firstName: "U",
            lastName: "V",
            customerID: "user-3",
            isVerified: true
        )
        let stubUserUC = StubGetCurrentUserUseCase(user: user)
        let stubRecentUC = StubGetRecentOrdersUseCase()
        let stubAllUC = StubGetAllOrdersUseCase()
        let vm = OrdersViewModel(
            getAllOrdersUseCase: stubAllUC,
            getRecentOrdersUseCase: stubRecentUC,
            getCurrentUserUseCase: stubUserUC
        )

        vm.loadOrders()

        XCTAssertTrue(stubAllUC.executeCalled, "Should invoke GetAllOrdersUseCase")
        XCTAssertEqual(stubAllUC.capturedCustomerID, user.customerID)

        if case .loading = vm.ordersState {
            // ok
        } else {
            XCTFail("Expected .loading state before completion")
        }

        let allOrders: [Order] = []
        stubAllUC.completionHandler?(.success(allOrders))

        guard case .success(let orders) = vm.ordersState else {
            return XCTFail("Expected .success state after completion")
        }
        XCTAssertEqual(orders.count, allOrders.count)
    }

    func testLoadAllOrders_error() {
        let user = User(
            email: "p@q.com",
            phone: nil,
            firstName: "P",
            lastName: "Q",
            customerID: "user-4",
            isVerified: false
        )
        let stubUserUC = StubGetCurrentUserUseCase(user: user)
        let stubRecentUC = StubGetRecentOrdersUseCase()
        let stubAllUC = StubGetAllOrdersUseCase()
        let vm = OrdersViewModel(
            getAllOrdersUseCase: stubAllUC,
            getRecentOrdersUseCase: stubRecentUC,
            getCurrentUserUseCase: stubUserUC
        )

        vm.loadOrders()

        stubAllUC.completionHandler?(.error("Server failure"))

        guard case .failure(let message) = vm.ordersState else {
            return XCTFail("Expected .failure state on error")
        }
        XCTAssertEqual(message, "Server failure")
    }

    func testLoadRecentOrders_withoutUser_setsFailureState() {
        let stubUserUC = StubGetCurrentUserUseCase(user: nil)
        let stubRecentUC = StubGetRecentOrdersUseCase()
        let stubAllUC = StubGetAllOrdersUseCase()
        let vm = OrdersViewModel(
            getAllOrdersUseCase: stubAllUC,
            getRecentOrdersUseCase: stubRecentUC,
            getCurrentUserUseCase: stubUserUC
        )

        vm.loadRecentOrders()

        guard case .failure(let message) = vm.recentOrdersState else {
            return XCTFail("Expected .failure when no user is signed in")
        }
        XCTAssertEqual(message, "You must be signed in to see your recent orders.")
    }

    func testLoadAllOrders_withoutUser_setsFailureState() {
        let stubUserUC = StubGetCurrentUserUseCase(user: nil)
        let stubRecentUC = StubGetRecentOrdersUseCase()
        let stubAllUC = StubGetAllOrdersUseCase()
        let vm = OrdersViewModel(
            getAllOrdersUseCase: stubAllUC,
            getRecentOrdersUseCase: stubRecentUC,
            getCurrentUserUseCase: stubUserUC
        )

        vm.loadOrders()

        guard case .failure(let message) = vm.recentOrdersState else {
            return XCTFail("Expected .failure when no user is signed in for orders")
        }
        XCTAssertEqual(message, "You must be signed in to see your orders.")
    }
}
