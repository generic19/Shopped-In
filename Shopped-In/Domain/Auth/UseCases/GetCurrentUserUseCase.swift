import FirebaseAuth
class GetCurrentUserUseCase {
    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func execute()->FirebaseAuth.User? {
        authRepository.getCurrentUser()
    }
}

