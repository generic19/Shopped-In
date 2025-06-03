

struct GetDefaultAddressUseCase {
    let repository: AddressRepository
    
    func execute(customerAccessToken: String, completion: @escaping (AddressResponse) -> Void) {
        repository.getDefaultAddress(customerAccessToken: customerAccessToken, completion: completion)
    }
}
