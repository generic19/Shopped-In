//
//  BrandProductsViewModelTest.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 26/06/2025.
//
import XCTest
@testable import Shopped_In

fileprivate class StubGetProductsByBrandUseCase: GetProductsByBrandUseCase {
    var executeCalled = false
    var receivedBrand: Brand?
    var receivedSort: ProductsSort?
    var resultToReturn: CategorizedProductsResponse?
    
    func execute(
        brand: Brand,
        sort: ProductsSort,
        completion: @escaping (CategorizedProductsResponse) -> Void
    ) {
        executeCalled = true
        receivedBrand = brand
        receivedSort = sort
        if let result = resultToReturn {
            completion(result)
        }
    }
}

final class BrandProductsViewModelTest: XCTestCase {
    let brandA = Brand(id: "b1", title: "Brand A", image: nil)
    let dummyItem = CategorizedProductListItem(
        item: ProductListItem(id: "p1", title: "Test", image: nil, price: Amount(value: 9.99, currency: .USD)),
        category: Category(demographic: .men, productType: .shirts, onSale: false)
    )
    
    private func makeViewModel(
        response: CategorizedProductsResponse? = nil
    ) -> (vm: BrandProductsViewModel, stub: StubGetProductsByBrandUseCase) {
        let stub = StubGetProductsByBrandUseCase()
        stub.resultToReturn = response
        let vm = BrandProductsViewModel(getProductsByBrandUseCase: stub)
        return (vm, stub)
    }
    
    func testGetProducts_callsUseCase() {
        let stub = StubGetProductsByBrandUseCase()
        stub.resultToReturn = .success([dummyItem])
        
        let vm = BrandProductsViewModel(getProductsByBrandUseCase: stub)
        vm.getProducts(brand: brandA)
        
        XCTAssertTrue(stub.executeCalled)
        XCTAssertEqual(stub.receivedBrand, brandA)
        XCTAssertEqual(stub.receivedSort, vm.sort)
    }
    
    func testGetProducts_success_resetsError_andStopsLoading() {
        let stub = StubGetProductsByBrandUseCase()
        stub.resultToReturn = .success([dummyItem])
        
        let vm = BrandProductsViewModel(getProductsByBrandUseCase: stub)
        vm.isLoading = true
        
        vm.getProducts(brand: brandA)
        
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
    }
    
    func testGetProducts_error_setsError_andStopsLoading() {
        let stub = StubGetProductsByBrandUseCase()
        let errorMsg = "Network failed"
        stub.resultToReturn = .error(errorMsg)
        
        let vm = BrandProductsViewModel(getProductsByBrandUseCase: stub)
        vm.isLoading = true
        
        vm.getProducts(brand: brandA)
        
        XCTAssertFalse(vm.isLoading)
        XCTAssertEqual(vm.errorMessage, errorMsg)
    }
}
