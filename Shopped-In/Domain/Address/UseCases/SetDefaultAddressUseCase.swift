
struct SetDefaultAddressUseCase {
    let repository: AddressRepository
    
    func execute(customerAccessToken: String, addressId: String, completion: @escaping (AddressOperationResponse) -> Void) {
        repository.setDefaultAddress(customerAccessToken: customerAccessToken, addressId: addressId, completion: completion)
    }
}
