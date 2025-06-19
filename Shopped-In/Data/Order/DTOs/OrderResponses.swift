
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
    let nodes: [OrderDTO]
}
