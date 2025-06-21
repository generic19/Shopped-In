import Combine

class ProfileViewModel: ObservableObject {
    @Published var user: User?
    private var getCurrentUserUseCase: GetCurrentUserUseCase = DIContainer.resolve()

    private var signOut: SignOutUseCase = DIContainer.resolve()

    init() {
        getCurrentUserUseCase.execute().assign(to: &$user)
    }

    func signOutUser(completion: @escaping () -> Void) {
        signOut.execute {
            let deleteCartUseCase: DeleteCartUseCase = DIContainer.resolve()
            deleteCartUseCase.execute()
            completion()
        }
    }
}
