import FirebaseAuth
import UIKit

protocol AuthRepository{
    func signUp(user: User,password: String, completion: @escaping (Error?) -> Void)
    func signIn(email:String,password: String, completion: @escaping (Error?) -> Void)
    func signOut(completion: @escaping () -> Void)
    func getCurrentUser() -> User?
    func signInWithGoogle(presentingViewController: UIViewController, completion: @escaping (Error?) -> Void)

}
