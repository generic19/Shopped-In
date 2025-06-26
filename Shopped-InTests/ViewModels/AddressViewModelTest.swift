//
//  AddressViewModelTest.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 26/06/2025.
//
import XCTest
@testable import Shopped_In

enum TestError: Error, Equatable {
    case sampleError
}

class StubGetCustomerAccessTokenUseCase: GetCustomerAccessTokenUseCase {
    private let tokenToReturn: String?
    init(token: String?) { self.tokenToReturn = token }
    func execute() -> String? { tokenToReturn }
}

class StubGetAddressesUseCase: GetAddressesUseCase {
    var executeCalled = false
    var receivedToken: String?
    var resultToReturn: AddressResponse?

    func execute(customerAccessToken: String, completion: @escaping (AddressResponse) -> Void) {
        executeCalled = true
        receivedToken = customerAccessToken
        if let result = resultToReturn {
            completion(result)
        }
    }
}

class StubDeleteAddressUseCase: DeleteAddressUseCase {
    var executeCalled = false
    var receivedToken: String?
    var receivedAddressId: String?
    var resultToReturn: AddressOperationResponse?

    func execute(customerAccessToken: String, addressId: String, completion: @escaping (AddressOperationResponse) -> Void) {
        executeCalled = true
        receivedToken = customerAccessToken
        receivedAddressId = addressId
        if let result = resultToReturn {
            completion(result)
        }
    }
}

class StubSetDefaultAddressUseCase: SetDefaultAddressUseCase {
    var executeCalled = false
    var receivedToken: String?
    var receivedAddressId: String?
    var resultToReturn: AddressOperationResponse?

    func execute(customerAccessToken: String, addressId: String, completion: @escaping (AddressOperationResponse) -> Void) {
        executeCalled = true
        receivedToken = customerAccessToken
        receivedAddressId = addressId
        if let result = resultToReturn {
            completion(result)
        }
    }
}

final class AddressViewModelTests: XCTestCase {
    let address1 = Address(id: "1", name: "Home", address1: "Cairo", address2: nil, city: "City", country: "Country", phone: "+201020304050")
    let address2 = Address(id: "2", name: "Work", address1: "Giza", address2: "Flat 5", city: "City", country: "Country", phone: "+201000000000")

    func testInit_assignsCustomerAccessToken() {
        let expectedToken = "token123"
        let stubToken = StubGetCustomerAccessTokenUseCase(token: expectedToken)
        let vm = AddressViewModel(
            getAddressUseCase: StubGetAddressesUseCase(),
            deleteAddressUseCase: StubDeleteAddressUseCase(),
            setDefaultAddressUseCase: StubSetDefaultAddressUseCase(),
            getCustomerAccessTokenUseCase: stubToken
        )
        XCTAssertEqual(vm.customerAccessToken, expectedToken)
    }

    func testGetAddresses_success() {
        let stubToken = StubGetCustomerAccessTokenUseCase(token: "token123")
        let stubGet = StubGetAddressesUseCase()
        let stubDelete = StubDeleteAddressUseCase()
        let stubSet = StubSetDefaultAddressUseCase()
        let vm = AddressViewModel(
            getAddressUseCase: stubGet,
            deleteAddressUseCase: stubDelete,
            setDefaultAddressUseCase: stubSet,
            getCustomerAccessTokenUseCase: stubToken
        )
        stubGet.resultToReturn = .success(addresses: [address1, address2], defaultAddress: address2)

        vm.getAddresses()

        XCTAssertTrue(stubGet.executeCalled)
        XCTAssertEqual(stubGet.receivedToken, vm.customerAccessToken)
        XCTAssertEqual(vm.addresses, [address1, address2])
        XCTAssertEqual(vm.defaultAddress, address2)
    }

    func testGetAddresses_error() {
        let stubToken = StubGetCustomerAccessTokenUseCase(token: "token123")
        let stubGet = StubGetAddressesUseCase()
        let stubDelete = StubDeleteAddressUseCase()
        let stubSet = StubSetDefaultAddressUseCase()
        let vm = AddressViewModel(
            getAddressUseCase: stubGet,
            deleteAddressUseCase: stubDelete,
            setDefaultAddressUseCase: stubSet,
            getCustomerAccessTokenUseCase: stubToken
        )
        let errMsg = "Fetch error"
        stubGet.resultToReturn = .error(errMsg)

        vm.getAddresses()

        XCTAssertEqual(vm.errorMessage, errMsg)
    }

    func testDeleteAddress_success() {
        let stubToken = StubGetCustomerAccessTokenUseCase(token: "token123")
        let stubGet = StubGetAddressesUseCase()
        let stubDelete = StubDeleteAddressUseCase()
        let stubSet = StubSetDefaultAddressUseCase()
        let vm = AddressViewModel(
            getAddressUseCase: stubGet,
            deleteAddressUseCase: stubDelete,
            setDefaultAddressUseCase: stubSet,
            getCustomerAccessTokenUseCase: stubToken
        )
        
        stubGet.resultToReturn = .success(addresses: [address1], defaultAddress: address1)
        vm.getAddresses()
        stubGet.executeCalled = false

        stubDelete.resultToReturn = .success
        vm.deleteAddress(address1)

        XCTAssertTrue(stubDelete.executeCalled)
        XCTAssertEqual(stubDelete.receivedAddressId, address1.id)
        XCTAssertEqual(vm.successMessage, "Address deleted successfully")
        XCTAssertTrue(stubGet.executeCalled)
    }

    func testDeleteAddress_errorMessage() {
        let stubToken = StubGetCustomerAccessTokenUseCase(token: "token123")
        let stubGet = StubGetAddressesUseCase()
        let stubDelete = StubDeleteAddressUseCase()
        let stubSet = StubSetDefaultAddressUseCase()
        let vm = AddressViewModel(
            getAddressUseCase: stubGet,
            deleteAddressUseCase: stubDelete,
            setDefaultAddressUseCase: stubSet,
            getCustomerAccessTokenUseCase: stubToken
        )
        let customErr = "Delete failed"
        stubDelete.resultToReturn = .errorMessage(customErr)

        vm.deleteAddress(address1)

        XCTAssertEqual(vm.errorMessage, customErr)
    }

    func testDeleteAddress_failure() {
        let stubToken = StubGetCustomerAccessTokenUseCase(token: "token123")
        let stubGet = StubGetAddressesUseCase()
        let stubDelete = StubDeleteAddressUseCase()
        let stubSet = StubSetDefaultAddressUseCase()
        let vm = AddressViewModel(
            getAddressUseCase: stubGet,
            deleteAddressUseCase: stubDelete,
            setDefaultAddressUseCase: stubSet,
            getCustomerAccessTokenUseCase: stubToken
        )
        stubDelete.resultToReturn = .failure(TestError.sampleError)

        vm.deleteAddress(address1)

        XCTAssertEqual(vm.errorMessage, TestError.sampleError.localizedDescription)
    }

    func testSetDefaultAddress_success() {
        let stubToken = StubGetCustomerAccessTokenUseCase(token: "token123")
        let stubGet = StubGetAddressesUseCase()
        let stubDelete = StubDeleteAddressUseCase()
        let stubSet = StubSetDefaultAddressUseCase()
        let vm = AddressViewModel(
            getAddressUseCase: stubGet,
            deleteAddressUseCase: stubDelete,
            setDefaultAddressUseCase: stubSet,
            getCustomerAccessTokenUseCase: stubToken
        )
        
        stubGet.resultToReturn = .success(addresses: [address1], defaultAddress: address1)
        vm.getAddresses()
        stubGet.executeCalled = false

        stubSet.resultToReturn = .success
        vm.setDefaultAddress(address2)

        XCTAssertTrue(stubSet.executeCalled)
        XCTAssertEqual(stubSet.receivedAddressId, address2.id)
        XCTAssertEqual(vm.successMessage, "Default address set successfully")
        XCTAssertTrue(stubGet.executeCalled)
    }

    func testSetDefaultAddress_errorMessage() {
        let stubToken = StubGetCustomerAccessTokenUseCase(token: "token123")
        let stubGet = StubGetAddressesUseCase()
        let stubDelete = StubDeleteAddressUseCase()
        let stubSet = StubSetDefaultAddressUseCase()
        let vm = AddressViewModel(
            getAddressUseCase: stubGet,
            deleteAddressUseCase: stubDelete,
            setDefaultAddressUseCase: stubSet,
            getCustomerAccessTokenUseCase: stubToken
        )
        let customErr = "Set default failed"
        stubSet.resultToReturn = .errorMessage(customErr)

        vm.setDefaultAddress(address1)

        XCTAssertEqual(vm.errorMessage, customErr)
    }

    func testSetDefaultAddress_failure() {
        let stubToken = StubGetCustomerAccessTokenUseCase(token: "token123")
        let stubGet = StubGetAddressesUseCase()
        let stubDelete = StubDeleteAddressUseCase()
        let stubSet = StubSetDefaultAddressUseCase()
        let vm = AddressViewModel(
            getAddressUseCase: stubGet,
            deleteAddressUseCase: stubDelete,
            setDefaultAddressUseCase: stubSet,
            getCustomerAccessTokenUseCase: stubToken
        )
        stubSet.resultToReturn = .failure(TestError.sampleError)

        vm.setDefaultAddress(address1)

        XCTAssertEqual(vm.errorMessage, TestError.sampleError.localizedDescription)
    }
}
