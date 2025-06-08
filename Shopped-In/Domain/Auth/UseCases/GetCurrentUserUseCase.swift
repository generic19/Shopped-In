
class GetCurrentUserUseCase {
    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func execute(completion: @escaping (Result<User?, Error>) -> Void) {
        authRepository.getCurrentUser(completion: completion)
    }
}

