
import Foundation

protocol CartRepository {
    func createCart(variantId: String, quantity: Int, completion: @escaping (CartOperationResponse) -> Void)

    func fetchCart(completion: @escaping (Result<Cart, Error>) -> Void)

    func addItem(variantId: String, quantity: Int, completion: @escaping (CartOperationResponse) -> Void)

    func updateItemQuantity(lineItemId: String, quantity: Int, completion: @escaping (CartOperationResponse) -> Void)

    func removeItem(lineItemId: String, completion: @escaping (CartOperationResponse) -> Void)

    func addDiscountCode(code: String, completion: @escaping (CartOperationResponse) -> Void)
    
    func deleteCart()
}
