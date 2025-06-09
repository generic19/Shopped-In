//
//  Untitled.swift
//  Shopped-In
//
//  Created by Ayatullah Salah on 08/06/2025.
//

import Buy
import Foundation

class APIAuthRemoteDataSourceImpl: APIAuthRemoteDataSource{
    private let service: APIService
    init(service: APIService) {
        self.service = service
    }
    
    
    
    
    func createCustomer(email: String, password: String, phone: String, firstName: String, lastName: String,completion: @escaping (Result<String, Error>) -> Void){
        let mutation = Storefront.buildMutation { q in
            q.customerCreate(input: Storefront.CustomerCreateInput(email: email, password: password, firstName: firstName, lastName: lastName, phone: phone)) { q in
                q.customer { q in
                    q.id()
                }
                q.userErrors { q in
                    q.field()
                    q.message()
                }
            }
        }
        
        service.client.mutateGraphWith(mutation) { (result, error) in
            if let error = error {
                completion(.failure(error))
                
                
                
            } else if let result = result {
                if let customerId = result.customerCreate?.customer?.id {
                    
                    completion(.success(customerId.rawValue))
                } else if let errors = result.customerCreate?.userErrors, !errors.isEmpty {
                    let errors = errors.compactMap(\.message).joined(separator: ", ")
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : errors])))
                    
                } else {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "No data returned"])))
                    
                }
            } else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "No result"])))
                
                
                
            }
        }.resume()
    }
    func signInCustomer(email: String, password: String,completion: @escaping (Result<String, Error>) -> Void){
        let mutation = Storefront.buildMutation { q in
            q.customerAccessTokenCreate(input: Storefront.CustomerAccessTokenCreateInput(email: email, password: password)) { q in
                q.customerAccessToken { q in
                    q.accessToken()
                }
                q.customerUserErrors { q in
                    q.message()
                }
            }
        }
        service.client.mutateGraphWith(mutation) { (result, error) in
            
            
            if let error  = error {
                print("  sign in error  \(error ) ")
                completion(.failure(error))
                
                return
            }
            
            if  let accessToken = result?.customerAccessTokenCreate?.customerAccessToken?.accessToken{
                completion(.success(accessToken))
            }else if let errors  = result?.customerAccessTokenCreate?.customerUserErrors{
                
                let errors = errors.compactMap(\.message).joined(separator: ", ")
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : errors])))
            }else{
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "No data returned"])))

            }
                
                
            
            
        }.resume()
    }
    func signOutCustomer(token: String,completion: @escaping () -> Void){
        let muation = Storefront.buildMutation { q in
            q.customerAccessTokenDelete(customerAccessToken: token) { _ in}
        }
        
            service.client.mutateGraphWith(muation) { (_,_) in
            completion()
        }.resume()

    }
    
    
}
