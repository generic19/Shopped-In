//
//  BrandsViewModelTest.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 26/06/2025.
//
import XCTest
import Combine
@testable import Shopped_In

class StubGetBrandsUseCase: GetBrandsUseCase {
    private(set) var callCount = 0
    private(set) var lastSort: BrandsSort?
    private(set) var lastForceNetwork: Bool?
    
    var response: BrandsResponse = .success([])
    
    func execute(
        sort: BrandsSort,
        forceNetwork: Bool,
        completion: @escaping (BrandsResponse) -> Void
    ) {
        callCount += 1
        lastSort = sort
        lastForceNetwork = forceNetwork
        completion(response)
    }
}

final class BrandsViewModelTests: XCTestCase {
    private var stubUseCase: StubGetBrandsUseCase!
    private var viewModel: BrandsViewModel!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        stubUseCase = StubGetBrandsUseCase()
        viewModel = BrandsViewModel(getBrandsUseCase: stubUseCase)
        cancellables = []
    }
    
    override func tearDown() {
        cancellables = nil
        viewModel = nil
        stubUseCase = nil
        super.tearDown()
    }
    
    func testGetBrandsSuccess() {
        let expectedBrands = [Brand(id: "1", title: "Alpha", image: nil)]
        stubUseCase.response = .success(expectedBrands)
        
        viewModel.getBrands()
        
        XCTAssertEqual(stubUseCase.callCount, 1, "Should call use case exactly once")
        XCTAssertEqual(stubUseCase.lastSort, .title, "Should use the default sort `.title`")
        XCTAssertEqual(stubUseCase.lastForceNetwork, false, "Should pass forceNetwork=false by default")
        
        XCTAssertFalse(viewModel.isLoading, "Loading should be false after completion")
        XCTAssertNil(viewModel.errorMessage, "errorMessage should be nil on success")
        XCTAssertEqual(viewModel.allBrands, expectedBrands, "allBrands should be set to the returned brands")
    }
    
    func testGetBrandsError() {
        let errorText = "Network error"
        stubUseCase.response = .error(errorText)
        
        viewModel.getBrands()
        
        XCTAssertEqual(stubUseCase.callCount, 1)
        XCTAssertFalse(viewModel.isLoading, "Loading should be false after error")
        XCTAssertEqual(viewModel.errorMessage, errorText, "errorMessage should match the returned error")
        XCTAssertNil(viewModel.allBrands, "allBrands should remain nil on error")
    }
    
    func testChangingSortTriggersGetBrands() {
        stubUseCase.response = .success([])
        XCTAssertEqual(stubUseCase.callCount, 0)
        
        viewModel.sort = .relevance
        
        XCTAssertEqual(stubUseCase.callCount, 1, "Setting `sort` should trigger a getBrands() call")
        XCTAssertEqual(stubUseCase.lastSort, .relevance, "Use case should be called with the new sort value")
    }
}
