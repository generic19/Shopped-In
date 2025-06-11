
struct AddAddressUseCase {
    let repository: AddressRepository

    func execute(forCustomerWithAccessToken customerAccessToken: String, address: Address, completion: @escaping (AddressOperationResponse) -> Void) {
        repository.createAddress(forCustomerWithAccessToken: customerAccessToken, address: address, completion: completion)
    }
}
