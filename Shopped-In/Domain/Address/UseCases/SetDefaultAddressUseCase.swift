
protocol SetDefaultAddressUseCase {
    func execute(
        customerAccessToken: String,
        addressId: String,
        completion: @escaping (AddressOperationResponse) -> Void
    )
}

class SetDefaultAddressUseCaseImpl: SetDefaultAddressUseCase {
    private let repository: AddressRepository

    init(repository: AddressRepository) {
        self.repository = repository
    }

    func execute(
        customerAccessToken: String,
        addressId: String,
        completion: @escaping (AddressOperationResponse) -> Void
    ) {
        repository.setDefaultAddress(
            customerAccessToken: customerAccessToken,
            addressId: addressId,
            completion: completion
        )
    }
}
