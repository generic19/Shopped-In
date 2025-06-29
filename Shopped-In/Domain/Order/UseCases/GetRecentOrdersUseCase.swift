
protocol GetRecentOrdersUseCase {
    func execute(customerID: String, completion: @escaping (GetOrdersResult) -> Void)
}

class GetRecentOrdersUseCaseImpl: GetRecentOrdersUseCase {
    private let repository: OrderRepository

    init(repository: OrderRepository) {
        self.repository = repository
    }

    func execute(customerID: String, completion: @escaping (GetOrdersResult) -> Void) {
        repository.getRecentOrders(customerID: customerID, completion: completion)
    }
}
