//
//  ProductDetailViewModelTest.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 26/06/2025.
//
import XCTest
import Combine
@testable import Shopped_In

fileprivate class StubFetchProductUseCase: FetchProductUseCase {
    var executedId: String?
    var productToReturn: Product?
    func execute(id: String, completion: @escaping (Product?) -> Void) {
        executedId = id
        completion(productToReturn)
    }
}

fileprivate class StubCheckFavoriteUseCase: CheckFavoriteProductUseCase {
    var executedProductID: String?
    var favoriteToReturn: Bool = false
    func execute(productID: String, completion: @escaping (Bool) -> Void) {
        executedProductID = productID
        completion(favoriteToReturn)
    }
}

fileprivate class StubAddFavoriteUseCase: AddFavoriteProductUseCase {
    var addedProduct: Product?
    var executeCalled = false
    var errorToReturn: Error? = nil
    func execute(product: Product, completion: @escaping (Error?) -> Void) {
        executeCalled = true
        addedProduct = product
        completion(errorToReturn)
    }
}

fileprivate class StubRemoveFavoriteUseCase: RemoveFavoriteProductUseCase {
    var removedProductID: String?
    var executeCalled = false
    var errorToReturn: Error? = nil
    func execute(productID: String, completion: @escaping (Error?) -> Void) {
        executeCalled = true
        removedProductID = productID
        completion(errorToReturn)
    }
}

final class ProductDetailViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    func testFetchProduct_invokesFetchAndCheckFavorite_andUpdatesBindings() {
        let fetchStub = StubFetchProductUseCase()
        let checkStub = StubCheckFavoriteUseCase()
        let sampleProduct = Product(
            id: "1",
            title: "SampleTitle",
            price: "",
            images: [],
            sizes: [],
            colors: [],
            rating: 0,
            description: "",
            reviews: [],
            variants: []
        )
        fetchStub.productToReturn = sampleProduct
        checkStub.favoriteToReturn = true

        let vm = ProductDetailViewModel(
            fetchProductUseCase: fetchStub,
            addFavoriteUseCase: StubAddFavoriteUseCase(),
            removeFavoriteUseCase: StubRemoveFavoriteUseCase(),
            checkFavoriteUseCase: checkStub
        )

        let productExpectation = expectation(description: "Product is set")
        let favoriteExpectation = expectation(description: "Favorite status is set")

        vm.$product
            .dropFirst()
            .sink { product in
                XCTAssertEqual(product?.id, sampleProduct.id)
                productExpectation.fulfill()
            }
            .store(in: &cancellables)

        vm.$isFavorite
            .dropFirst()
            .sink { isFav in
                XCTAssertTrue(isFav)
                favoriteExpectation.fulfill()
            }
            .store(in: &cancellables)

        vm.fetchProduct(by: "1")

        wait(for: [productExpectation, favoriteExpectation], timeout: 1)
        XCTAssertFalse(vm.isLoading)
        XCTAssertEqual(fetchStub.executedId, "1")
        XCTAssertEqual(checkStub.executedProductID, sampleProduct.title)
    }

    func testToggleFavorite_whenNotFavorite_invokesAddFavorite_andUpdatesFlag() {
        let product = Product(
            id: "1",
            title: "SampleTitle",
            price: "",
            images: [],
            sizes: [],
            colors: [],
            rating: 0,
            description: "",
            reviews: [],
            variants: []
        )
        let addStub = StubAddFavoriteUseCase()
        let removeStub = StubRemoveFavoriteUseCase()

        let vm = ProductDetailViewModel(
            fetchProductUseCase: StubFetchProductUseCase(),
            addFavoriteUseCase: addStub,
            removeFavoriteUseCase: removeStub,
            checkFavoriteUseCase: StubCheckFavoriteUseCase()
        )
        vm.product = product
        vm.isFavorite = false

        let expectation = self.expectation(description: "isFavorite toggled to true")

        vm.$isFavorite
            .dropFirst()
            .sink { isFav in
                XCTAssertTrue(isFav)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        vm.toggleFavorite()

        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(addStub.executeCalled)
        XCTAssertEqual(addStub.addedProduct?.id, product.id)
    }

    func testToggleFavorite_whenFavorite_invokesRemoveFavorite_andUpdatesFlag() {
        let product = Product(
            id: "1",
            title: "SampleTitle",
            price: "",
            images: [],
            sizes: [],
            colors: [],
            rating: 0,
            description: "",
            reviews: [],
            variants: []
        )
        let addStub = StubAddFavoriteUseCase()
        let removeStub = StubRemoveFavoriteUseCase()

        let vm = ProductDetailViewModel(
            fetchProductUseCase: StubFetchProductUseCase(),
            addFavoriteUseCase: addStub,
            removeFavoriteUseCase: removeStub,
            checkFavoriteUseCase: StubCheckFavoriteUseCase()
        )
        vm.product = product
        vm.isFavorite = true

        let expectation = self.expectation(description: "isFavorite toggled to false")

        vm.$isFavorite
            .dropFirst()
            .sink { isFav in
                XCTAssertFalse(isFav)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        vm.toggleFavorite()

        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(removeStub.executeCalled)
        XCTAssertEqual(removeStub.removedProductID, product.title)
    }
}
