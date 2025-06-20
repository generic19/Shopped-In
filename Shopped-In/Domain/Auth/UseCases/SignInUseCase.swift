protocol SignInUseCase {
    func execute(email: String, password: String, completion: @escaping (Error?) -> Void)
}

class SignInUseCaseImpl: SignInUseCase {
    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func execute(email: String, password: String, completion: @escaping (Error?) -> Void) {
        authRepository.signIn(email: email, password: password, completion: completion)
    }
}
