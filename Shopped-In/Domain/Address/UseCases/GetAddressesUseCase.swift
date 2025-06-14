
struct GetAddressesUseCase {
    private let repository: AddressRepository
    init(repository: AddressRepository) {
        self.repository = repository
    }
    func execute(customerAccessToken: String, completion: @escaping (AddressResponse) -> Void) {
        repository.fetchAddresses(customerAccessToken: customerAccessToken, completion: completion)
    }
}
