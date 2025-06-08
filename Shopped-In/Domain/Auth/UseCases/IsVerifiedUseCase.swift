
class IsVerifiedUseCase {
    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func execute(completion: @escaping (Result<Bool, Error>) -> Void) {
        authRepository.isVerified(completion: completion)
    }
}

