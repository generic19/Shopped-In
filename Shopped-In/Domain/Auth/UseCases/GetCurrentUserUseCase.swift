import Combine

class GetCurrentUserUseCase {
    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func execute() -> AnyPublisher<User?, Never> {
        return authRepository.currentUser
    }
}
