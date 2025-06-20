
protocol GetAllOrdersUseCase {
    func execute(customerID: String, completion: @escaping (GetOrdersResult) -> Void)
}

class GetAllOrdersUseCaseImpl: GetAllOrdersUseCase {
    private let repository: OrderRepository

    init(repository: OrderRepository) {
        self.repository = repository
    }

    func execute(customerID: String, completion: @escaping (GetOrdersResult) -> Void) {
        repository.getAllOrders(customerID: customerID, completion: completion)
    }
}
