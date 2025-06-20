import Alamofire
import Foundation

protocol OrderRemoteDataSource {
    func createOrder(cart: Cart, user: User, address: Address, discountCode: String?, fixedDiscount: Double?, fractionalDiscount: Double?, completion: @escaping (Result<Order, OrderError>) -> Void)
    
    func getAllOrders(customerID: String, completion: @escaping (Result<[Order], OrderError>) -> Void)
    
    func getRecentOrders(customerID: String, completion: @escaping (Result<[Order], OrderError>) -> Void)
}
