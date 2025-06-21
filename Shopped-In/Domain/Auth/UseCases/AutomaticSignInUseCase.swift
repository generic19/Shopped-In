protocol AutomaticSignInUseCase {
    func execute(completion: @escaping (Bool) -> Void)
}

class AutomaticSignInUseCaseImpl: AutomaticSignInUseCase {
    private let authRepo: AuthRepository

    init(authRepo: AuthRepository) {
        self.authRepo = authRepo
    }

    func execute(completion: @escaping (Bool) -> Void) {
        authRepo.automaticSignIn(completion: completion)
    }
}
