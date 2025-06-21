protocol UpdateAddressUseCase {
    func execute(
        customerAccessToken: String,
        addressId: String,
        address: Address,
        completion: @escaping (AddressOperationResponse) -> Void
    )
}

class UpdateAddressUseCaseImpl: UpdateAddressUseCase {
    private let repository: AddressRepository

    init(repository: AddressRepository) {
        self.repository = repository
    }

    func execute(
        customerAccessToken: String,
        addressId: String,
        address: Address,
        completion: @escaping (AddressOperationResponse) -> Void
    ) {
        repository.updateAddress(
            customerAccessToken: customerAccessToken,
            addressId: addressId,
            address: address,
            completion: completion
        )
    }
}
