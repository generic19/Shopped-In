
import Foundation

class CartSessionLocalDataSourceImpl: CartSessionLocalDataSource {
    private static let key = "shopify_cart_id"

    var cartId: String? {
        get { UserDefaults.standard.string(forKey: CartSessionLocalDataSourceImpl.key) }
        set {
            if let newValue = newValue {
                UserDefaults.standard.set(newValue, forKey: CartSessionLocalDataSourceImpl.key)
            } else {
                UserDefaults.standard.removeObject(forKey: CartSessionLocalDataSourceImpl.key)
            }
        }
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: CartSessionLocalDataSourceImpl.key)
    }
}
