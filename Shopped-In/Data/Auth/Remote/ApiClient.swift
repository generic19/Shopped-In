

//
//  ApiClient.swift
//  shopify
//
//  Created by Ayatullah Salah on 29/05/2025.
//

import Foundation
import Buy
class ApiClient {
    static let shared = ApiClient()
    private let client : Graph.Client
    private init() {
        client = Graph.Client(shopDomain:SHOPIFY_SHOP_DOMAIN, apiKey:STOREFRONT_API_ACCESS_TOKEN)
        
     
    
    }
    
    func createCustomer(email: String, password: String, phone: String, firstName: String, lastName: String) {
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
        
        client.mutateGraphWith(mutation) { (result, error) in
            if let error = error {
                print("Mutation error: \(error.localizedDescription)")
            } else if let result = result {
                if let customerId = result.customerCreate?.customer?.id {
                    print("Customer created successfully with ID: \(customerId)")
                } else if let errors = result.customerCreate?.userErrors, !errors.isEmpty {
                    print("User errors:")
                    for err in errors {
                        print("- Field: \(err.field ?? []) Message: \(err.message)")
                    }
                } else {
                    print("Customer creation failed with unknown error")
                }
            } else {
                print("No result and no error returned.")
            }
        }.resume()
    }

    
    func signInCustomer(email: String, password: String,completion: @escaping (String?) -> Void) {
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
        client.mutateGraphWith(mutation) { (result, error) in
           
            
            if let error  = error {
                print("  sign in error  \(error ) ")
                completion(nil)

                return
            }
            
            guard let accessToken = result?.customerAccessTokenCreate?.customerAccessToken?.accessToken else {
                print(result?.customerAccessTokenCreate?.customerUserErrors.compactMap({$0.message}).joined(separator: ", ") ?? "Unknown error")

                
                return }
            completion(accessToken)

            print("  sign in token \(accessToken)" )
        }.resume()
    }
    
    func signOutCustomer(token: String,completion: @escaping () -> Void) {
        let muation = Storefront.buildMutation { q in
            q.customerAccessTokenDelete(customerAccessToken: token) { _ in}
        }
        
        client.mutateGraphWith(muation) { (_,_) in
            completion()
        }.resume()
    }

    
}
