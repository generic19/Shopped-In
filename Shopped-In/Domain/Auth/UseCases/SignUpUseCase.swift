protocol SignUpUseCase {
    func execute(user: User, password: String, completion: @escaping (Error?) -> Void)
}

class SignUpUseCaseImpl: SignUpUseCase {
    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func execute(user: User, password: String, completion: @escaping (Error?) -> Void) {
        authRepository.signUp(user: user, password: password, completion: completion)
    }
}
