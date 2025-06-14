
struct DeleteAddressUseCase {
    let repository: AddressRepository
    
    func execute(customerAccessToken: String, addressId: String, completion: @escaping (AddressOperationResponse) -> Void) {
        repository.deleteAddress(customerAccessToken: customerAccessToken, addressId: addressId, completion: completion)
    }
}
