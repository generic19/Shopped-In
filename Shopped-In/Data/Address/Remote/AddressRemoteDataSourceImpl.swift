import Buy
import Combine

class AddressRemoteDataSourceImpl: AddressRemoteDataSource {
    private let service: BuyAPIService

    init(service: BuyAPIService) {
        self.service = service
    }

    func fetchAddresses(customerAccessToken: String, completion: @escaping (Result<(addresses:[AddressDTO], defaultAddress: AddressDTO?), Error>) -> Void) {
        let query = Storefront.buildQuery {
            $0.customer(customerAccessToken: customerAccessToken) {
                $0.addresses(first: 100) {
                    $0.nodes {
                        $0.id()
                        $0.address1()
                        $0.address2()
                        $0.city()
                        $0.country()
                        $0.firstName()
                        $0.phone()
                    }
                }
                $0.defaultAddress {
                    $0.id()
                    $0.address1()
                    $0.address2()
                    $0.city()
                    $0.country()
                    $0.firstName()
                    $0.phone()
                }
            }
        }

        service.client.queryGraphWith(query) { response, error in
            if let addresses = response?.customer?.addresses.nodes {
                let defaultAddress = response?.customer?.defaultAddress
                completion(.success((addresses, defaultAddress)))
            } else {
                completion(.failure(error ?? .noData))
            }
        }.resume()
    }

    func createAddress(forCustomerWithAccessToken customerAccessToken: String, address: Address, completion: @escaping (AddressOperationResponse) -> Void) {
        let mutation = Storefront.buildMutation {
            $0.customerAddressCreate(customerAccessToken: customerAccessToken, address: Storefront.MailingAddressInput.from(address: address)
            ) {
                $0.customerUserErrors {
                    $0.message()
                }
            }
        }

        service.client.mutateGraphWith(mutation) { mutation, error in
            if let errors = mutation?.customerAddressCreate?.customerUserErrors, !errors.isEmpty {
                let errorMessages = errors.compactMap { $0.message }.joined(separator: ", ")

                completion(.errorMessage(errorMessages))

            } else if error != nil {
                completion(.failure(error!))
            } else {
                completion(.success)
            }
        }.resume()
    }

    func deleteAddress(customerAccessToken: String, addressId: String, completion: @escaping (AddressOperationResponse) -> Void) {
        let mutation = Storefront.buildMutation {
            $0.customerAddressDelete(id: .init(rawValue: addressId), customerAccessToken: customerAccessToken) {
                $0.customerUserErrors {
                    $0.message()
                }
            }
        }

        service.client.mutateGraphWith(mutation) { mutation, error in
            if let errors = mutation?.customerAddressDelete?.customerUserErrors, !errors.isEmpty {
                let errorMessages = errors.compactMap { $0.message }.joined(separator: ", ")
                completion(.errorMessage(errorMessages))
            } else if let error = error {
                completion(.failure(error))
            } else {
                completion(.success)
            }
        }.resume()
    }

    func setDefaultAddress(customerAccessToken: String, addressId: String, completion: @escaping (AddressOperationResponse) -> Void) {
        let mutation = Storefront.buildMutation {
            $0.customerDefaultAddressUpdate(customerAccessToken: customerAccessToken, addressId: .init(rawValue: addressId)) {
                $0.customerUserErrors {
                    $0.message()
                }
            }
        }

        service.client.mutateGraphWith(mutation) { mutation, error in
            if let errors = mutation?.customerDefaultAddressUpdate?.customerUserErrors, !errors.isEmpty {
                let errorMessages = errors.compactMap { $0.message }.joined(separator: ", ")
                completion(.errorMessage(errorMessages))
            } else if let error = error {
                completion(.failure(error))
            } else {
                completion(.success)
            }
        }.resume()
    }

    func updateAddress(customerAccessToken: String, addressId: String, address: Address, completion: @escaping (AddressOperationResponse) -> Void) {
        let mutation = Storefront.buildMutation {
            $0.customerAddressUpdate(customerAccessToken: customerAccessToken, id: .init(rawValue: addressId), address: Storefront.MailingAddressInput.from(address: address)) {
                $0.customerUserErrors {
                    $0.message()
                }
            }
        }

        service.client.mutateGraphWith(mutation) { mutation, error in
            if let errors = mutation?.customerAddressUpdate?.customerUserErrors, !errors.isEmpty {
                let errorMessages = errors.compactMap { $0.message }.joined(separator: ", ")
                completion(.errorMessage(errorMessages))
            } else if let error = error {
                completion(.failure(error))
            } else {
                completion(.success)
            }
        }.resume()
    }
}
