//
//  Untitled.swift
//  Shopped-In
//
//  Created by Ayatullah Salah on 08/06/2025.
//

import Buy
import Foundation

class APIAuthRemoteDataSourceImpl: APIAuthRemoteDataSource {
    private let service: APIService
    
    init(service: APIService) {
        self.service = service
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
            } else if let errors = result?.customerAccessTokenCreate?.customerUserErrors {
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
            $0.customerAccessTokenDelete(customerAccessToken: token) {_ in }
        }
        
        service.client.mutateGraphWith(muation) { (_,_) in
            completion()
        }.resume()
    }
}
