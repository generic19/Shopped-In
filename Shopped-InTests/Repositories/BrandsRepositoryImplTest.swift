//
//  BrandsRepositoryImplTest.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 26/06/2025.
//
import XCTest
@testable import Shopped_In
import Buy

fileprivate class MockBrandRemoteDataSource: BrandRemoteDataSource {
    private(set) var invokedSort: BrandsSort?
    private(set) var invokedForceNetwork: Bool?
    var completionHandler: ((Result<[BrandDTO], Error>) -> Void)?

    func getAllBrands(
        sort: BrandsSort,
        forceNetwork: Bool,
        completion: @escaping (Result<[BrandDTO], Error>) -> Void
    ) {
        invokedSort = sort
        invokedForceNetwork = forceNetwork
        completionHandler = completion
    }
}

final class BrandRepositoryImplTests: XCTestCase {
    func testGetAllBrands_callsRemoteWithCorrectParameters() {
        let mockRemote = MockBrandRemoteDataSource()
        let repository = BrandRepositoryImpl(remote: mockRemote)
        let didCallCompletion = expectation(description: "Completion handler invoked")

        repository.getAllBrands(sort: .mostRecent, forceNetwork: false) { _ in
            didCallCompletion.fulfill()
        }

        XCTAssertEqual(mockRemote.invokedSort, .mostRecent)
        XCTAssertEqual(mockRemote.invokedForceNetwork, false)

        mockRemote.completionHandler?(.success([]))
        waitForExpectations(timeout: 0.5)
    }

    func testGetAllBrands_success_returnsEmptyBrandList() {
        let mockRemote = MockBrandRemoteDataSource()
        let repository = BrandRepositoryImpl(remote: mockRemote)
        let didCallCompletion = expectation(description: "Completion handler invoked")
        var receivedBrands: [Brand]?

        repository.getAllBrands(sort: .title, forceNetwork: true) { response in
            if case let .success(brands) = response {
                receivedBrands = brands
            } else {
                XCTFail("Expected a .success response, got \(response) instead")
            }
            didCallCompletion.fulfill()
        }

        mockRemote.completionHandler?(.success([]))
        waitForExpectations(timeout: 0.5)

        XCTAssertEqual(receivedBrands, [])
    }

    func testGetAllBrands_failure_returnsErrorMessage() {
        let mockRemote = MockBrandRemoteDataSource()
        let repository = BrandRepositoryImpl(remote: mockRemote)
        let didCallCompletion = expectation(description: "Completion handler invoked")
        var receivedError = false

        repository.getAllBrands(sort: .relevance, forceNetwork: true) { response in
            if case let .error(_) = response {
                receivedError = true
            } else {
                XCTFail("Expected an .error response, got \(response) instead")
            }
            didCallCompletion.fulfill()
        }

        mockRemote.completionHandler?(.failure(Graph.QueryError.noData))
        waitForExpectations(timeout: 0.5)

        XCTAssertTrue(receivedError)
    }
}
