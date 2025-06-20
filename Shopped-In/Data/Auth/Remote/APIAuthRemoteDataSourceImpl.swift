//
//  Untitled.swift
//  Shopped-In
//
//  Created by Ayatullah Salah on 08/06/2025.
//

import Buy
import Foundation

class APIAuthRemoteDataSourceImpl: APIAuthRemoteDataSource {
    private let service: BuyAPIService
    
    init(service: BuyAPIService) {
        self.service = service
    }
    
    func getCustomer(token: String, completion: @escaping (Result<User, Error>) -> Void) {
        let query = Storefront.buildQuery {
            $0.customer(customerAccessToken: token) {
                $0.email()
                .phone()
                .firstName()
                .lastName()
                .id()
            }
        }
        
        service.client.queryGraphWith(query) { query, error in
            if let error {
                completion(.failure(error))
                return
            }
            guard
                let email = query?.customer?.email,
                let firstName = query?.customer?.firstName,
                let lastName = query?.customer?.lastName,
                let customerID = query?.customer?.id.rawValue
            else {
                completion(.failure(AuthError.noData))
                return
            }
            
            let phone = query?.customer?.phone
            let user = User(email: email, phone: phone, firstName: firstName, lastName: lastName, customerID: customerID)
            
            completion(.success(user))
        }.resume()
    }
    
    func createCustomer(user: User, password: String,completion: @escaping (Error?) -> Void) {
        let input = Storefront.CustomerCreateInput(
            email: user.email,
            password: password,
            firstName: user.firstName,
            lastName: user.lastName,
            phone: user.phone,
            acceptsMarketing: true,
        )
        
        let mutation = Storefront.buildMutation {
            $0.customerCreate(input: input) {
                $0.customerUserErrors {
                    $0.field()
                    .message()
                }
            }
        }
        
        service.client.mutateGraphWith(mutation) { (result, error) in
            if let error = error {
                completion(error)
                return
            } else if let errors = result?.customerCreate?.customerUserErrors, !errors.isEmpty {
                completion(AuthError.apiErrors(errors))
                return
            }
            
            completion(nil)
        }.resume()
    }
    
    func signInCustomer(email: String, password: String, completion: @escaping (Result<CustomerAccessToken, Error>) -> Void){
        let input = Storefront.CustomerAccessTokenCreateInput(email: email, password: password)
        
        let mutation = Storefront.buildMutation {
            $0.customerAccessTokenCreate(input: input) {
                $0.customerAccessToken {
                    $0.accessToken()
                }
                $0.customerUserErrors {
                    $0.field()
                        .message()
                }
            }
        }
        
        service.client.mutateGraphWith(mutation) { (result, error) in
            if let error = error {
                completion(.failure(error))
                return
            } else if let errors = result?.customerAccessTokenCreate?.customerUserErrors, !errors.isEmpty {
                completion(.failure(AuthError.apiErrors(errors)))
            }
            
            if let accessToken = result?.customerAccessTokenCreate?.customerAccessToken?.accessToken{
                completion(.success(accessToken))
            }else{
                completion(.failure(AuthError.noData))
            }
        }.resume()
    }
    
    func signOutCustomer(token: String,completion: @escaping () -> Void){
        let muation = Storefront.buildMutation {
            $0.customerAccessTokenDelete(customerAccessToken: token) {
                $0.deletedAccessToken()
            }
        }
        
        service.client.mutateGraphWith(muation) { (_,_) in
            completion()
        }.resume()
    }
}
