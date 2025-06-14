
import Foundation

struct CartSessionRepo {
    private static let key = "shopify_cart_id"

    static var cartId: String? {
        get { UserDefaults.standard.string(forKey: key) }
        set {
            if let newValue = newValue {
                UserDefaults.standard.set(newValue, forKey: key)
            } else {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
