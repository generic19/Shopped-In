
protocol AddAddressUseCase {
    func execute(
        forCustomerWithAccessToken customerAccessToken: String,
        address: Address,
        completion: @escaping (AddressOperationResponse) -> Void
    )
}

class AddAddressUseCaseImpl: AddAddressUseCase {
    private let repository: AddressRepository

    init(repository: AddressRepository) {
        self.repository = repository
    }

    func execute(
        forCustomerWithAccessToken customerAccessToken: String,
        address: Address,
        completion: @escaping (AddressOperationResponse) -> Void
    ) {
        repository.createAddress(
            forCustomerWithAccessToken: customerAccessToken,
            address: address,
            completion: completion
        )
    }
}
