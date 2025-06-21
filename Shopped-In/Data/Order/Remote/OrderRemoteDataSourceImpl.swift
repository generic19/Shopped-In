//
//  OrderRemoteDataSourceImpl.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 19/06/2025.
//


import Alamofire
import Foundation

class OrderRemoteDataSourceImpl: OrderRemoteDataSource {
    private let service: AlamofireAPIService
    
    init(service: AlamofireAPIService) {
        self.service = service
    }
    
    func createOrder(cart: Cart, user: User, address: Address, discountCode: String?, fixedDiscount: Double?, fractionalDiscount: Double?, completion: @escaping (Result<Order, OrderError>) -> Void) {
        
        guard let customerID = user.customerID else {
            completion(.failure(.missingValue(parameter: "user", field: "customerID")))
            return
        }
        
        let discount: OrderCreateRequest.Discount? = if let discountCode {
            if let fixedDiscount {
                OrderCreateRequest.Discount(
                    code: discountCode,
                    policy: .fixed(fixedDiscount, currency: "EGP")
                )
            } else if let fractionalDiscount {
                OrderCreateRequest.Discount(
                    code: discountCode,
                    policy: .fraction(fractionalDiscount)
                )
            } else { nil }
        } else { nil }
        
        let request = OrderCreateRequest(
            customerID: customerID,
            discount: discount,
            order: OrderCreateRequest.Order(
                currencyCode: "EGP",
                lineItems: cart.items.map {
                    OrderCreateRequest.Order.LineItem(
                        variantID: $0.variantId,
                        quantity: $0.quantity
                    )
                },
                shippingAddress: ShippingAddress(
                    address1: address.address1,
                    address2: address.address2 ?? "",
                    city: address.city,
                    firstName: user.firstName,
                    lastName: user.lastName,
                    phone: address.phone
                )
            )
        )
        
        service.request(graphQL: request) { result in
            switch result {
                case .success(let response):
                    let order = response.data.orderCreate.order.toDomain()
                    completion(.success(order))
                    
                case .failure(let error):
                    completion(.failure(.alamofireError(error: error)))
            }
        }
    }
    
    func getAllOrders(customerID: String, completion: @escaping (Result<[Order], OrderError>) -> Void) {
        getOrders(customerID: customerID, limit: 100, completion: completion)
    }
    
    func getRecentOrders(customerID: String, completion: @escaping (Result<[Order], OrderError>) -> Void) {
        getOrders(customerID: customerID, limit: 3, completion: completion)
    }
    
    private func getOrders(customerID: String, limit: Int, completion: @escaping (Result<[Order], OrderError>) -> Void) {
        let request = OrdersRequest(customerID: customerID, limit: limit)
        
        service.request(graphQL: request) { result in
            switch result {
                case .success(let response):
                    let orders = response.data.orders.nodes.map({ $0.toDomain() })
                    completion(.success(orders))
                    
                case .failure(let error):
                    completion(.failure(.alamofireError(error: error)))
            }
        }
    }
}
