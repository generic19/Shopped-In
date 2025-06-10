import FirebaseAuth

protocol AuthRepository{
    func signUp(user: User,password: String, completion: @escaping (Error?) -> Void)
    func signIn(email:String,password: String, completion: @escaping (Error?) -> Void)
    func signOut(completion: @escaping () -> Void)
    func getCurrentUser() -> User?
}
