
import Combine

protocol AddressRepository {
    func fetchAddresses(customerAccessToken: String, completion: @escaping (AddressResponse) -> Void)
    
    func createAddress(forCustomerWithAccessToken customerAccessToken: String, address: Address, completion: @escaping (AddressOperationResponse) -> Void)
    
    func deleteAddress(customerAccessToken: String, addressId: String, completion: @escaping (AddressOperationResponse) -> Void)
    
    func getDefaultAddress(customerAccessToken: String, completion: @escaping (AddressResponse) -> Void)
    
    func setDefaultAddress(customerAccessToken: String, addressId: String, completion: @escaping (AddressOperationResponse) -> Void)
    
    func updateAddress(customerAccessToken: String, addressId: String, address: Address, completion: @escaping (AddressOperationResponse) -> Void)
}

enum AddressResponse {
    case success([Address])
    case error(String)
}
