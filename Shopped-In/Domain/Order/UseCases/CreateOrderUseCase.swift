
class CreateOrderUseCase {
    private let repository: OrderRepository
    
    init(repository: OrderRepository) {
        self.repository = repository
    }
    
    func execute(cart: Cart, user: User, address: Address, discountCode: String?, fixedDiscount: Double?, fractionalDiscount: Double?, completion: @escaping (CreateOrderResult) -> Void) {
        
        repository.createOrder(cart: cart, user: user, address: address, discountCode: discountCode, fixedDiscount: fixedDiscount, fractionalDiscount: fractionalDiscount, completion: completion)
    }
}
