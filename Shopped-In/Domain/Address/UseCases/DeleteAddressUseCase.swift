protocol DeleteAddressUseCase {
    func execute(
        customerAccessToken: String,
        addressId: String,
        completion: @escaping (AddressOperationResponse) -> Void
    )
}

class DeleteAddressUseCaseImpl: DeleteAddressUseCase {
    private let repository: AddressRepository

    init(repository: AddressRepository) {
        self.repository = repository
    }

    func execute(
        customerAccessToken: String,
        addressId: String,
        completion: @escaping (AddressOperationResponse) -> Void
    ) {
        repository.deleteAddress(
            customerAccessToken: customerAccessToken,
            addressId: addressId,
            completion: completion
        )
    }
}
