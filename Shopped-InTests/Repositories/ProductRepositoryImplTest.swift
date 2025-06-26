//
//  ProductRepositoryImplTest.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 26/06/2025.
//
import XCTest
import Buy
@testable import Shopped_In

fileprivate class ProductRemoteDataSourceMock: ProductRemoteDataSource {
    var getProductsForBrandCalled = false
    var getProductsForBrandBrandID: String?
    var getProductsForBrandSort: ProductsSort?
    var getProductsForBrandCompletion: ((Result<[CategorizedProductListItem], Error>) -> Void)?

    var getProductsCalled = false
    var getProductsSort: ProductsSort?
    var getProductsCompletion: ((Result<[CategorizedProductListItem], Error>) -> Void)?

    var fetchProductCalled = false
    var fetchProductID: String?
    var fetchProductCompletion: ((Product?) -> Void)?

    func getProductsForBrand(
        brandID: String,
        sort: ProductsSort,
        completion: @escaping (Result<[CategorizedProductListItem], Error>) -> Void
    ) {
        getProductsForBrandCalled = true
        getProductsForBrandBrandID = brandID
        getProductsForBrandSort = sort
        getProductsForBrandCompletion = completion
    }

    func getProducts(
        sort: ProductsSort,
        completion: @escaping (Result<[CategorizedProductListItem], Error>) -> Void
    ) {
        getProductsCalled = true
        getProductsSort = sort
        getProductsCompletion = completion
    }

    func fetchProduct(
        by id: String,
        completion: @escaping (Product?) -> Void
    ) {
        fetchProductCalled = true
        fetchProductID = id
        fetchProductCompletion = completion
    }
}

final class ProductRepositoryImplTests: XCTestCase {
    private var mockRemote: ProductRemoteDataSourceMock!
    private var repository: ProductRepositoryImpl!

    override func setUp() {
        super.setUp()
        mockRemote = ProductRemoteDataSourceMock()
        repository = ProductRepositoryImpl(remote: mockRemote)
    }

    override func tearDown() {
        repository = nil
        mockRemote = nil
        super.tearDown()
    }

    func testGetProductsByBrand_successPath_callsRemoteAndReturnsSuccess() {
        let expectedID = "brand123"
        let expectedSort: ProductsSort = .price
        var receivedResponse: CategorizedProductsResponse?
        
        repository.getProductsByBrand(brandID: expectedID, sort: expectedSort) { response in
            receivedResponse = response
        }
        
        XCTAssertTrue(mockRemote.getProductsForBrandCalled)
        XCTAssertEqual(mockRemote.getProductsForBrandBrandID, expectedID)
        XCTAssertEqual(mockRemote.getProductsForBrandSort, expectedSort)

        mockRemote.getProductsForBrandCompletion?(.success([]))
        
        if case .success(let items)? = receivedResponse {
            XCTAssertEqual(items.count, 0)
        } else {
            XCTFail("Expected success response")
        }
    }

    func testGetProductsByBrand_failurePath_callsRemoteAndReturnsError() {
        let expectedID = "brandXYZ"
        let expectedSort: ProductsSort = .title
        var receivedResponse: CategorizedProductsResponse?
        
        repository.getProductsByBrand(brandID: expectedID, sort: expectedSort) { response in
            receivedResponse = response
        }
        
        XCTAssertTrue(mockRemote.getProductsForBrandCalled)
        
        let graphError = Graph.QueryError.noData
        
        mockRemote.getProductsForBrandCompletion?(.failure(graphError))
        
        if case .error(_) = receivedResponse {
            // ok
        } else {
            XCTFail("Expected error response")
        }
    }

    func testGetProducts_successPath_callsRemoteAndReturnsSuccess() {
        var received: CategorizedProductsResponse?
        repository.getProducts(sort: .relevance) { received = $0 }
        
        XCTAssertTrue(mockRemote.getProductsCalled)
        XCTAssertEqual(mockRemote.getProductsSort, .relevance)
        
        mockRemote.getProductsCompletion?(.success([]))
        if case .success(let items)? = received {
            XCTAssertTrue(items.isEmpty)
        } else {
            XCTFail("Expected success")
        }
    }

    func testGetProducts_failurePath_callsRemoteAndReturnsError() {
        var received: CategorizedProductsResponse?
        repository.getProducts(sort: .mostRecent) { received = $0 }
        
        XCTAssertTrue(mockRemote.getProductsCalled)
        
        let err = Graph.QueryError.noData
        
        mockRemote.getProductsCompletion?(.failure(err))
        if case .error(_) = received {
            // ok
        } else {
            XCTFail("Expected error response")
        }
    }

    func testFetchProduct_forwardsIDAndResult() {
        let expectedID = "prod123"
        var receivedProduct: Product?

        repository.fetchProduct(by: expectedID) { receivedProduct = $0 }

        XCTAssertTrue(mockRemote.fetchProductCalled)
        XCTAssertEqual(mockRemote.fetchProductID, expectedID)

        let dummy = Product(
            id: "p", title: "T", price: "10", images: [],
            sizes: [], colors: [], rating: 0, description: "",
            reviews: [], variants: []
        )
        mockRemote.fetchProductCompletion?(dummy)
        XCTAssertEqual(receivedProduct?.id, dummy.id)

        mockRemote.fetchProductCompletion?(nil)
        XCTAssertNil(receivedProduct)
    }
}
