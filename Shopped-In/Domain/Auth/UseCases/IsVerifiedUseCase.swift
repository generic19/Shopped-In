
class IsVerifiedUseCase {
    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func execute() -> Bool{
        authRepository.isVerified()
    }
}

