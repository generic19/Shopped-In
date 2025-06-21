import Combine
import Foundation

struct OrderListItem {
    let id: String
    let imageURL: URL?
    let title: String
    let totalAmount: String
}

extension Order {
    func toDisplayModel() -> OrderListItem {
        let firstTitle = items.first?.productTitle ?? "No Items!"
        
        let trimmedFirstTitle = if firstTitle.count > 30 {
            firstTitle.prefix(30).trimmingCharacters(in: .whitespacesAndNewlines) + "..."
        } else {
            firstTitle
        }
        
        let title = if items.count > 1 {
            "\(trimmedFirstTitle), and \(items.count - 1) more."
        } else {
            trimmedFirstTitle
        }
        
        return OrderListItem(
            id: id,
            imageURL: items.first?.image,
            title: title,
            totalAmount: String(format: "\(total.currency.rawValue) %.2f", total.value),
        )
    }
}

class OrdersViewModel: ObservableObject {
    enum OrdersState {
        case initial
        case loading
        case success(orders: [Order])
        case failure(errorMessage: String)
    }
    
    private let getAllOrdersUseCase: GetAllOrdersUseCase
    private let getRecentOrdersUseCase: GetRecentOrdersUseCase
    private let getCurrentUserUseCase: GetCurrentUserUseCase
    
    @Published var recentOrdersState: OrdersState = .initial
    @Published var ordersState: OrdersState = .initial
    @Published var currentUser: User?
    
    init(getAllOrdersUseCase: GetAllOrdersUseCase, getRecentOrdersUseCase: GetRecentOrdersUseCase, getCurrentUserUseCase: GetCurrentUserUseCase) {
        self.getAllOrdersUseCase = getAllOrdersUseCase
        self.getRecentOrdersUseCase = getRecentOrdersUseCase
        self.getCurrentUserUseCase = getCurrentUserUseCase
        
        getCurrentUserUseCase.execute().assign(to: &$currentUser)
    }
    
    func loadRecentOrders() {
        guard let customerID = currentUser?.customerID else {
            recentOrdersState = .failure(errorMessage: "You must be signed in to see your recent orders.")
            return
        }
        
        recentOrdersState = .loading
        
        getRecentOrdersUseCase.execute(customerID: customerID) { result in
            switch result {
                case .success(let orders):
                    self.recentOrdersState = .success(orders: orders)
                    
                case .error(let message):
                    self.recentOrdersState = .failure(errorMessage: message)
            }
        }
    }
    
    func loadOrders() {
        guard let customerID = currentUser?.customerID else {
            recentOrdersState = .failure(errorMessage: "You must be signed in to see your orders.")
            return
        }
        
        ordersState = .loading
        
        getAllOrdersUseCase.execute(customerID: customerID) { result in
            switch result {
                case .success(let orders):
                    self.ordersState = .success(orders: orders)
                    
                case .error(let message):
                    self.ordersState = .failure(errorMessage: message)
            }
        }
    }
}
