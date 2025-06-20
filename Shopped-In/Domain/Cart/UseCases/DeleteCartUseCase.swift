
protocol DeleteCartUseCase {
    func execute()
}

class DeleteCartUseCaseImpl: DeleteCartUseCase {
    private let repo: CartRepository

    init(repo: CartRepository) {
        self.repo = repo
    }

    func execute() {
        repo.deleteCart()
    }
}


