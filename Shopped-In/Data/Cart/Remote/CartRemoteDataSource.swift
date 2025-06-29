
import Buy
protocol CartRemoteDataSource {
    func createCart(variantId: String, quantity: Int, completion: @escaping (CartCreationResponse) -> Void)

    func fetchCart(by id: String, completion: @escaping (Result<Storefront.Cart, Error>) -> Void)

    func addItem(to cartId: String, variantId: String, quantity: Int, completion: @escaping (CartOperationResponse) -> Void)

    func updateItemQuantity(cartId: String, lineItemId: String, quantity: Int, completion: @escaping (CartOperationResponse) -> Void)

    func removeItem(cartId: String, lineItemId: String, completion: @escaping (CartOperationResponse) -> Void)

    func addDiscountCode(cartId: String, code: String, completion: @escaping (CartOperationResponse) -> Void)
}
