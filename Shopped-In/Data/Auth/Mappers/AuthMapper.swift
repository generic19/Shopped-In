
import FirebaseAuth
import Buy


extension User {
    static func from(firebaseUser: FirebaseAuth.User, customer: Storefront.Customer) -> User? {
        guard
            let email = firebaseUser.email,
            let firstName = customer.firstName,
            let lastName = customer.lastName
        else { return nil }
        
        return User(
            email: email,
            phone: customer.phone,
            firstName: firstName,
            lastName: lastName,
            customerID: customer.id.rawValue
        )
    }
}
