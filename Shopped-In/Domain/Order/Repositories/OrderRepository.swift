
enum CreateOrderResult {
    case success(Order)
    case error(String)
}

enum GetOrdersResult {
    case success([Order])
    case error(String)
}

protocol OrderRepository {
    func createOrder(cart: Cart, user: User, address: Address, discountCode: String?, fixedDiscount: Double?, fractionalDiscount: Double?, completion: @escaping (CreateOrderResult) -> Void)
    
    func getAllOrders(customerID: String, completion: @escaping (GetOrdersResult) -> Void)
    
    func getRecentOrders(customerID: String, completion: @escaping (GetOrdersResult) -> Void)
}
