protocol AuthRepository{
    func signUp(user:User,password:String, completion: @escaping (Result<Void, Error>) -> Void)
    func signIn(email:String,password:String, completion: @escaping (Result<String, Error>) -> Void)
    func signOut()
}
