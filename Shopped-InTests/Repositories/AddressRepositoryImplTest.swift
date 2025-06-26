//
//  AddressRepository.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 26/06/2025.
//
import XCTest
@testable import Shopped_In

fileprivate class StubAddressRemoteDataSource: AddressRemoteDataSource {
    // MARK: fetchAddresses
    var fetchCalled = false
    var fetchCustomerAccessToken: String?
    var fetchResult: Result<(addresses: [AddressDTO], defaultAddress: AddressDTO?), Error>?
    func fetchAddresses(customerAccessToken: String,
                        completion: @escaping (Result<(addresses: [AddressDTO], defaultAddress: AddressDTO?), Error>) -> Void) {
        fetchCalled = true
        fetchCustomerAccessToken = customerAccessToken
        if let result = fetchResult {
            completion(result)
        }
    }

    // MARK: createAddress
    var createCalled = false
    var createParams: (token: String, address: Address)?
    var createResult: AddressOperationResponse?
    func createAddress(forCustomerWithAccessToken token: String,
                       address: Address,
                       completion: @escaping (AddressOperationResponse) -> Void) {
        createCalled = true
        createParams = (token, address)
        if let result = createResult {
            completion(result)
        }
    }

    // MARK: deleteAddress
    var deleteCalled = false
    var deleteParams: (token: String, addressId: String)?
    var deleteResult: AddressOperationResponse?
    func deleteAddress(customerAccessToken token: String,
                       addressId: String,
                       completion: @escaping (AddressOperationResponse) -> Void) {
        deleteCalled = true
        deleteParams = (token, addressId)
        if let result = deleteResult {
            completion(result)
        }
    }

    // MARK: setDefaultAddress
    var setDefaultCalled = false
    var setDefaultParams: (token: String, addressId: String)?
    var setDefaultResult: AddressOperationResponse?
    func setDefaultAddress(customerAccessToken token: String,
                           addressId: String,
                           completion: @escaping (AddressOperationResponse) -> Void) {
        setDefaultCalled = true
        setDefaultParams = (token, addressId)
        if let result = setDefaultResult {
            completion(result)
        }
    }

    // MARK: updateAddress
    var updateCalled = false
    var updateParams: (token: String, addressId: String, address: Address)?
    var updateResult: AddressOperationResponse?
    func updateAddress(customerAccessToken token: String,
                       addressId: String,
                       address: Address,
                       completion: @escaping (AddressOperationResponse) -> Void) {
        updateCalled = true
        updateParams = (token, addressId, address)
        if let result = updateResult {
            completion(result)
        }
    }
}

final class AddressRepositoryImplTests: XCTestCase {
    private var stubRemote: StubAddressRemoteDataSource!
    private var repository: AddressRepositoryImpl!

    override func setUp() {
        super.setUp()
        stubRemote = StubAddressRemoteDataSource()
        repository = AddressRepositoryImpl(remote: stubRemote)
    }

    override func tearDown() {
        repository = nil
        stubRemote = nil
        super.tearDown()
    }

    // MARK: fetchAddresses

    func testFetchAddresses_successForwardsEmptyArray() {
        stubRemote.fetchResult = .success((addresses: [], defaultAddress: nil))

        let exp = expectation(description: "fetch empty")
        repository.fetchAddresses(customerAccessToken: "token123") { resp in
            switch resp {
            case let .success(addresses, defaultAddress):
                XCTAssertEqual(addresses, [], "Expected no addresses")
                XCTAssertNil(defaultAddress, "Expected no default")
            case .error:
                XCTFail("Expected success path")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.1)

        XCTAssertTrue(stubRemote.fetchCalled)
        XCTAssertEqual(stubRemote.fetchCustomerAccessToken, "token123")
    }

    func testFetchAddresses_failureForwardsError() {
        let err = TestError.sampleError
        stubRemote.fetchResult = .failure(err)

        let exp = expectation(description: "fetch error")
        repository.fetchAddresses(customerAccessToken: "tokX") { resp in
            switch resp {
            case .success:
                XCTFail("Expected error path")
            case let .error(msg):
                XCTAssertFalse(msg.isEmpty, "Expected non-empty error message")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.1)
    }

    // MARK: createAddress

    func testCreateAddress_forwardsParamsAndSuccess() {
        stubRemote.createResult = .success

        let address = Address(id: "X", name: "", address1: "", address2: nil, city: "", country: "", phone: "")
        let exp = expectation(description: "create success")
        repository.createAddress(forCustomerWithAccessToken: "tkn", address: address) { resp in
            if case .success = resp {
                // OK
            } else {
                XCTFail("Expected success")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.1)

        XCTAssertTrue(stubRemote.createCalled)
        XCTAssertEqual(stubRemote.createParams?.token, "tkn")
        XCTAssertEqual(stubRemote.createParams?.address, address)
    }

    func testCreateAddress_errorPaths() {
        // errorMessage
        stubRemote.createResult = .errorMessage("oops")
        let exp1 = expectation(description: "create errMsg")
        repository.createAddress(forCustomerWithAccessToken: "", address: Address(id:"",name:"",address1:"",address2:nil,city:"",country:"",phone:"")) {
            if case let .errorMessage(msg) = $0 {
                XCTAssertEqual(msg, "oops")
            } else { XCTFail() }
            exp1.fulfill()
        }

        // failure → errorMessage
        stubRemote.createResult = .failure(TestError.sampleError)
        let exp2 = expectation(description: "create failure")
        repository.createAddress(forCustomerWithAccessToken: "", address: Address(id:"",name:"",address1:"",address2:nil,city:"",country:"",phone:"")) {
            if case let .errorMessage(msg) = $0 {
                XCTAssertFalse(msg.isEmpty)
            } else { XCTFail() }
            exp2.fulfill()
        }

        wait(for: [exp1, exp2], timeout: 0.1)
    }

    // MARK: deleteAddress

    func testDeleteAddress_paths() {
        stubRemote.deleteResult = .success
        let exp1 = expectation(description: "del success")
        repository.deleteAddress(customerAccessToken: "T", addressId: "A") {
            if case .success = $0 { } else { XCTFail() }
            exp1.fulfill()
        }

        stubRemote.deleteResult = .errorMessage("err")
        let exp2 = expectation(description: "del errMsg")
        repository.deleteAddress(customerAccessToken: "", addressId: "") {
            if case let .errorMessage(msg) = $0 {
                XCTAssertEqual(msg, "err")
            } else { XCTFail() }
            exp2.fulfill()
        }

        stubRemote.deleteResult = .failure(TestError.sampleError)
        let exp3 = expectation(description: "del fail")
        repository.deleteAddress(customerAccessToken: "", addressId: "") {
            if case let .errorMessage(msg) = $0 {
                XCTAssertFalse(msg.isEmpty)
            } else { XCTFail() }
            exp3.fulfill()
        }

        wait(for: [exp1, exp2, exp3], timeout: 0.1)
    }

    // MARK: setDefaultAddress

    func testSetDefaultAddress_paths() {
        stubRemote.setDefaultResult = .success
        let exp1 = expectation(description: "setDef success")
        repository.setDefaultAddress(customerAccessToken: "T", addressId: "A") {
            if case .success = $0 { } else { XCTFail() }
            exp1.fulfill()
        }

        stubRemote.setDefaultResult = .errorMessage("e")
        let exp2 = expectation(description: "setDef errMsg")
        repository.setDefaultAddress(customerAccessToken: "", addressId: "") {
            if case let .errorMessage(m) = $0 {
                XCTAssertEqual(m, "e")
            } else { XCTFail() }
            exp2.fulfill()
        }

        stubRemote.setDefaultResult = .failure(TestError.sampleError)
        let exp3 = expectation(description: "setDef fail")
        repository.setDefaultAddress(customerAccessToken: "", addressId: "") {
            if case let .errorMessage(m) = $0 {
                XCTAssertFalse(m.isEmpty)
            } else { XCTFail() }
            exp3.fulfill()
        }

        wait(for: [exp1, exp2, exp3], timeout: 0.1)
    }

    // MARK: updateAddress

    func testUpdateAddress_paths() {
        stubRemote.updateResult = .success
        let addr = Address(id: "I", name: "", address1: "", address2: nil, city: "", country: "", phone: "")
        let exp1 = expectation(description: "upd success")
        repository.updateAddress(customerAccessToken: "t", addressId: "a", address: addr) {
            if case .success = $0 { } else { XCTFail() }
            exp1.fulfill()
        }

        stubRemote.updateResult = .errorMessage("msg")
        let exp2 = expectation(description: "upd errMsg")
        repository.updateAddress(customerAccessToken: "", addressId: "", address: addr) {
            if case let .errorMessage(m) = $0 {
                XCTAssertEqual(m, "msg")
            } else { XCTFail() }
            exp2.fulfill()
        }

        stubRemote.updateResult = .failure(TestError.sampleError)
        let exp3 = expectation(description: "upd fail")
        repository.updateAddress(customerAccessToken: "", addressId: "", address: addr) {
            if case let .errorMessage(m) = $0 {
                XCTAssertFalse(m.isEmpty)
            } else { XCTFail() }
            exp3.fulfill()
        }

        wait(for: [exp1, exp2, exp3], timeout: 0.1)
    }
}
