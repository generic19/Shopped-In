//
//  Untitled.swift
//  Shopped-In
//
//  Created by Omar Abdelaziz on 01/06/2025.
//

protocol AddressRemoteDataSource {
    func fetchAddresses(customerAccessToken: String, completion: @escaping (Result<(addresses:[AddressDTO], defaultAddress: AddressDTO?), Error>) -> Void)

    func createAddress(forCustomerWithAccessToken customerAccessToken: String, address: Address, completion: @escaping (AddressOperationResponse) -> Void)
    
    func deleteAddress(customerAccessToken: String, addressId: String, completion: @escaping (AddressOperationResponse) -> Void)
        
    func setDefaultAddress(customerAccessToken: String, addressId: String, completion: @escaping (AddressOperationResponse) -> Void)
    
    func updateAddress(customerAccessToken: String, addressId: String, address: Address, completion: @escaping (AddressOperationResponse) -> Void)
}


enum AddressOperationResponse{
    case success
    case failure(Error)
    case errorMessage(String)
}
