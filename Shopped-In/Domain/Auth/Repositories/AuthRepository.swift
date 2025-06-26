import UIKit
import Combine

protocol AuthRepository {
    var currentUser: AnyPublisher<User?, Never> { get }
    
    func signUp(user: User,password: String, completion: @escaping (Error?) -> Void)
    func signIn(email:String,password: String, completion: @escaping (Error?) -> Void)
    func signOut(completion: @escaping () -> Void)
    func signInWithGoogle(presentingViewController: UIViewController, completion: @escaping (Error?) -> Void)
    func automaticSignIn(completion: @escaping (Bool) -> Void)
    func resendVerificationEmail()
    func reloadUser()
}
