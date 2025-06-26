import Combine

class ProfileViewModel: ObservableObject {
    @Published var user: User?
    
    private let getCurrentUserUseCase: GetCurrentUserUseCase
    private let signOut: SignOutUseCase
    private let deleteCartUseCase: DeleteCartUseCase

    init(getCurrentUserUseCase: GetCurrentUserUseCase, signOut: SignOutUseCase, deleteCartUseCase: DeleteCartUseCase) {
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.signOut = signOut
        self.deleteCartUseCase = deleteCartUseCase
    }

    func load() {
        getCurrentUserUseCase.execute().assign(to: &$user)
    }
    
    func signOutUser(completion: @escaping () -> Void) {
        signOut.execute {
            self.deleteCartUseCase.execute()
            completion()
        }
    }
}
