import Foundation
import Alamofire

class OrderRepositoryImpl: OrderRepository {
    private let remote: OrderRemoteDataSource
    
    init(remote: OrderRemoteDataSource) {
        self.remote = remote
    }
    
    func createOrder(cart: Cart, user: User, address: Address, discountCode: String?, fixedDiscount: Double?, fractionalDiscount: Double?, completion: @escaping (CreateOrderResult) -> Void) {
        
        remote.createOrder(cart: cart, user: user, address: address, discountCode: discountCode, fixedDiscount: fixedDiscount, fractionalDiscount: fractionalDiscount) { result in
            
            switch result {
                case .success(let order):
                    completion(.success(order))
                    
                case .failure(let error):
                    completion(.error(error.localizedDescription))
            }
        }
    }
    
    func getAllOrders(customerID: String, completion: @escaping (GetOrdersResult) -> Void) {
        remote.getAllOrders(customerID: customerID) { result in
            switch result {
                case .success(let orders):
                    completion(.success(orders))
                    
                case .failure(let error):
                    completion(.error(error.localizedDescription))
            }
        }
    }
    
    func getRecentOrders(customerID: String, completion: @escaping (GetOrdersResult) -> Void) {
        remote.getRecentOrders(customerID: customerID) { result in
            switch result {
                case .success(let orders):
                    completion(.success(orders))
                    
                case .failure(let error):
                    completion(.error(error.localizedDescription))
            }
        }
    }
}


enum OrderError: LocalizedError {
    case missingValue(parameter: String, field: String?)
    case alamofireError(error: AFError)
    
    var errorDescription: String? {
        switch self {
            case .missingValue(let parameter, let field):
                let location = if let field {
                    "parameter \(parameter) field \(field)"
                } else {
                    "parameter \(parameter)"
                }
                
                return "Missing value for \(location)."
                
            case .alamofireError(let error):
                return "Networking error: \(error.localizedDescription)"
        }
    }
}
