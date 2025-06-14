
import FirebaseAuth
import Buy


extension User {
    static func from(firebaseUser: FirebaseAuth.User, customer: Storefront.Customer?) -> User? {
        guard let email = firebaseUser.email else { return nil }
        
        return User(
            email: email,
            phone: customer?.phone,
            firstName: customer?.firstName,
            lastName: customer?.lastName,
            customerID: customer?.id.rawValue
        )
    }
}
