
import Buy

final class AddressRepositoryImpl: AddressRepository {
    private let remote: AddressRemoteDataSource

    init(remote: AddressRemoteDataSource) {
        self.remote = remote
    }

    func fetchAddresses(customerAccessToken: String, completion: @escaping (AddressResponse) -> Void) {
        remote.fetchAddresses(customerAccessToken: customerAccessToken) { result in
            switch result {
            case let .success(value):
                let addresses = value.compactMap({ $0.toDomain() })
                completion(.success(addresses))
            case let .failure(error):
                let message = (error as? Graph.QueryError).message(object: "addresses")
                completion(.error(message))
            }
        }
    }

    func createAddress(forCustomerWithAccessToken customerAccessToken: String, address: Address, completion: @escaping (AddressOperationResponse) -> Void) {
        remote.createAddress(forCustomerWithAccessToken: customerAccessToken, address: address) { result in
            switch result {
            case let .errorMessage(message):
                completion(.errorMessage(message))
            case let .failure(error):
                let message = (error as? Graph.QueryError).message(object: "creating address")
                completion(.errorMessage(message))
            case .success:
                completion(.success)
            }
        }
    }

    func deleteAddress(customerAccessToken: String, addressId: String, completion: @escaping (AddressOperationResponse) -> Void) {
        remote.deleteAddress(customerAccessToken: customerAccessToken, addressId: addressId) { result in
            switch result {
            case let .errorMessage(message):
                completion(.errorMessage(message))
            case let .failure(error):
                let message = (error as? Graph.QueryError).message(object: "deleting address")
                completion(.errorMessage(message))
            case .success:
                completion(.success)
            }
        }
    }

    func getDefaultAddress(customerAccessToken: String, completion: @escaping (AddressResponse) -> Void) {
        remote.getDefaultAddress(customerAccessToken: customerAccessToken) { result in
            switch result {
            case let .success(value):
                let address = value.toDomain()
                completion(.success([address]))
            case let .failure(error):
                let message = (error as? Graph.QueryError).message(object: "default address")
                completion(.error(message))
            }
        }
    }

    func setDefaultAddress(customerAccessToken: String, addressId: String, completion: @escaping (AddressOperationResponse) -> Void) {
        remote.setDefaultAddress(customerAccessToken: customerAccessToken, addressId: addressId) { result in
            switch result {
            case let .errorMessage(message):
                completion(.errorMessage(message))
            case let .failure(error):
                let message = (error as? Graph.QueryError).message(object: "setting default address")
                completion(.errorMessage(message))
            case .success:
                completion(.success)
            }
        }
    }

    func updateAddress(customerAccessToken: String, addressId: String, address: Address, completion: @escaping (AddressOperationResponse) -> Void) {
        remote.updateAddress(customerAccessToken: customerAccessToken, addressId: addressId, address: address) { result in
            switch result {
            case let .errorMessage(message):
                completion(.errorMessage(message))
            case let .failure(error):
                let message = (error as? Graph.QueryError).message(object: "updating address")
                completion(.errorMessage(message))
            case .success:
                completion(.success)
            }
        }
    }
}
