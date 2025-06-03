class SignInUseCase {
    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func execute(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        authRepository.signIn(email: email, password: password, completion: completion)
    }
}

