//
//  CategoriesViewModelTest.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 26/06/2025.
//
import XCTest
import Combine
@testable import Shopped_In

fileprivate class StubGetProductsUseCase: GetProductsUseCase {
    private let response: CategorizedProductsResponse

    private(set) var executeCalled = false
    private(set) var receivedSort: ProductsSort?

    init(response: CategorizedProductsResponse) {
        self.response = response
    }

    func execute(sort: ProductsSort, completion: @escaping (CategorizedProductsResponse) -> Void) {
        executeCalled = true
        receivedSort = sort
        completion(response)
    }
}

final class CategoriesViewModelTest: XCTestCase {
    var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func testLoadProducts_callsUseCase_withCurrentSort() {
        let stub = StubGetProductsUseCase(response: .success([]))
        let vm = CategoriesViewModel(getProductsUseCase: stub)

        vm.loadProducts()

        XCTAssertTrue(stub.executeCalled)
        XCTAssertEqual(stub.receivedSort, vm.sort)
    }

    func testLoadProducts_onSuccess_clearsErrorMessage() {
        let dummyItem = ProductListItem(
            id: "1",
            title: "Test",
            image: nil,
            price: Amount(value: 9.99, currency: .USD)
        )
        let categorized = CategorizedProductListItem(
            item: dummyItem,
            category: Category(
                demographic: .men,
                productType: .shirts,
                onSale: false
            )
        )
        let stub = StubGetProductsUseCase(response: .success([categorized]))
        let vm = CategoriesViewModel(getProductsUseCase: stub)

        vm.loadProducts()

        XCTAssertNil(vm.errorMessage)
    }

    func testLoadProducts_onError_setsErrorMessage() {
        let msg = "Network failure"
        let stub = StubGetProductsUseCase(response: .error(msg))
        let vm = CategoriesViewModel(getProductsUseCase: stub)

        vm.loadProducts()

        XCTAssertEqual(vm.errorMessage, msg)
    }

    func testLoadProducts_populatesProducts() {
        
        let dummyItem = ProductListItem(
            id: "1",
            title: "Sneaker",
            image: nil,
            price: Amount(value: 49.99, currency: .USD)
        )
        let categorized = CategorizedProductListItem(
            item: dummyItem,
            category: Category(
                demographic: .women,
                productType: .shoes,
                onSale: true
            )
        )
        let stub = StubGetProductsUseCase(response: .success([categorized]))
        let vm = CategoriesViewModel(getProductsUseCase: stub)

        let exp = expectation(description: "products published")
        var receivedProducts: [ProductListItem]?

        vm.$products
            .compactMap { $0 }        
            .sink { items in
                receivedProducts = items
                exp.fulfill()
            }
            .store(in: &cancellables)

        vm.loadProducts()
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertTrue(receivedProducts?.first?.id == dummyItem.id)
    }
}
