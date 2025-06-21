
struct OrderCreateResponse: Decodable {
    struct Data: Decodable {
        struct OrderCreate: Decodable {
            let order: OrderDTO
        }
        let orderCreate: OrderCreate
    }
    let data: Data
}

struct OrdersResponse: Decodable {
    struct Data: Decodable {
        struct Orders: Decodable {
            let nodes: [OrderDTO]
        }
        let orders: Orders
    }
    let data: Data
}
