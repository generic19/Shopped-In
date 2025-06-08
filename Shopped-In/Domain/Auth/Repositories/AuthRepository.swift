protocol AuthRepository{
    func signUp(user:User,password:String, completion: @escaping (Result<Void, Error>) -> Void)
    func signIn(email:String,password:String, completion: @escaping (Result<String, Error>) -> Void)
    func signOut(completion: @escaping () -> Void)
    func continueAsGuest()
    func isVerified(completion: @escaping (Result<Bool, Error>) -> Void)
    func getCurrentUser(completion: @escaping (Result<User?, Error>) -> Void)
}
