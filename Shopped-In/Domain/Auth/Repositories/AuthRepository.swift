import FirebaseAuth
protocol AuthRepository{
    func signUp(user:User,password:String, completion: @escaping (Result<Void, Error>) -> Void)
    //returns customer id 
    func signIn(email:String,password:String, completion: @escaping (Result<Void, Error>) -> Void)
    func signOut(completion: @escaping () -> Void)
    func continueAsGuest()
    func isVerified() -> Bool
    func getCurrentUser()->FirebaseAuth.User?
}
