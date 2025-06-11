
struct UpdateAddressUseCase {
    let repository: AddressRepository
    
    func execute(customerAccessToken: String, addressId: String, address: Address, completion: @escaping (AddressOperationResponse) -> Void) {
        repository.updateAddress(customerAccessToken: customerAccessToken, addressId: addressId, address: address, completion: completion)
    }
}
