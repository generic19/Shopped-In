////
////  Untitled.swift
////  Shopped-In
////
////  Created by Ayatullah Salah on 08/06/2025.
////
//
//import Buy
//
//class APIAuthRemoteDataSourceImpl: APIAuthRemoteDataSource{
//    private let service: APIService
//    
//    
//    
//
//    func createCustomer(email: String, password: String, phone: String, firstName: String, lastName: String,completion: @escaping (Result<String, Error>) -> Void){
//        let mutation = Storefront.buildMutation { q in
//            q.customerCreate(input: Storefront.CustomerCreateInput(email: email, password: password, firstName: firstName, lastName: lastName, phone: phone)) { q in
//                q.customer { q in
//                    q.id()
//                }
//                q.userErrors { q in
//                    q.field()
//                    q.message()
//                }
//            }
//        }
//        
//        client.mutateGraphWith(mutation) { (result, error) in
//            if let error = error {
//                print("Mutation error: \(error.localizedDescription)")
//            } else if let result = result {
//                if let customerId = result.customerCreate?.customer?.id {
//                    print("Customer created successfully with ID: \(customerId)")
//                } else if let errors = result.customerCreate?.userErrors, !errors.isEmpty {
//                    print("User errors:")
//                    for err in errors {
//                        print("- Field: \(err.field ?? []) Message: \(err.message)")
//                    }
//                } else {
//                    print("Customer creation failed with unknown error")
//                }
//            } else {
//                print("No result and no error returned.")
//            }
//        }.resume()
//    }
//    func signInCustomer(email: String, password: String,completion: @escaping (Result<String, Error>) -> Void){}
//    func signOutCustomer(token: String,completion: @escaping () -> Void){}
//    
//    
//}
