import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import Foundation

class AuthRepositoryImpl: AuthRepository {

    private let tokenRepository: TokenRepo
    private let apiSource: APIAuthRemoteDataSource
    private let firebaseSource: FireBaseAuthRemoteDataSource

    init(
        tokenRepository: TokenRepo,
        apiSource: APIAuthRemoteDataSource,
        firebaseSource: FireBaseAuthRemoteDataSource,
    ) {
        self.tokenRepository = tokenRepository
        self.apiSource = apiSource
        self.firebaseSource = firebaseSource
    }
    func signInWithGoogle(
        presentingViewController: UIViewController,
        completion: @escaping (Error?) -> Void
    ) {
        firebaseSource.signInWithGoogle(
            presentingViewController: presentingViewController
        ) { [weak self] result in
            switch result {
            case .success(let userDTO):
                print("sucess sign in with google")
                guard let email = userDTO.firebaseUser.email else {
                    completion(AuthError.noData)
                    return
                }

                self?.apiSource.signInCustomer(
                    email: email,
                    password: userDTO.randomToken
                ) { result in
                    switch result {
                    case .success(let accessToken):
                        print("success sign in ")
                        self?.tokenRepository.saveToken(accessToken)
                        print(accessToken)

                        print("acess token 2 \(self?.tokenRepository.loadToken())")
                        completion(nil)

                    case .failure:
                        print("failure sign in")
                        let name = userDTO.firebaseUser.displayName ?? ""
                        let nameComponents = name.split(separator: " ")
                        let firstName =
                            nameComponents.first.map(String.init) ?? "User"
                        let lastName = nameComponents.dropFirst().joined(
                            separator: " "
                        )

                        let user = User(
                            email: email,
                            phone: nil,
                            firstName: firstName,
                            lastName: lastName,
                            customerID: nil
                        )

                        self?.apiSource.createCustomer(
                            user: user,
                            password: userDTO.randomToken
                        ) { error in
                            if let error = error {
                                self?.firebaseSource.signOut()
                                completion(error)

                                return
                            }
                            self?.apiSource.signInCustomer(
                                email: user.email,
                                password: userDTO.randomToken
                            ) { result in
                                switch result {
                                case .success(let accessToken):
                                    self?.tokenRepository.saveToken(accessToken)
                                    completion(nil)

                                case .failure(let error):
                                    self?.firebaseSource.signOut()
                                    completion(error)
                                }
                            }

                        }

                    }
                }

            case .failure(let error):
                completion(error)
            }
        }
    }

    func signIn(
        email: String,
        password: String,
        completion: @escaping (Error?) -> Void
    ) {
        firebaseSource.signIn(email: email, password: password) {
            [weak self] result in
            switch result {
            case .success(let userDTO):
                self?.apiSource.signInCustomer(
                    email: email,
                    password: userDTO.randomToken
                ) { result in
                    switch result {
                    case .success(let accessToken):
                        self?.tokenRepository.saveToken(accessToken)
                        print("save token:\(self?.tokenRepository.loadToken())")
                        completion(nil)

                    case .failure(let error):
                        self?.firebaseSource.signOut()
                        completion(error)
                    }
                }

            case .failure(let error):
                completion(error)
            }
        }
    }

    func signUp(
        user: User,
        password: String,
        completion: @escaping (Error?) -> Void
    ) {
        firebaseSource.signUp(user: user, password: password) {
            [weak self] result in
            switch result {
            case .success(let userDTO):
                self?.apiSource.createCustomer(
                    user: user,
                    password: userDTO.randomToken
                ) { error in
                    if let error = error {
                        self?.firebaseSource.rollbackSignUp {
                            completion(error)
                        }
                        return
                    }

                    self?.apiSource.signInCustomer(
                        email: user.email,
                        password: userDTO.randomToken
                    ) { result in
                        switch result {
                        case .success(let accessToken):
                            self?.tokenRepository.saveToken(accessToken)
                            completion(nil)

                        case .failure(let error):
                            self?.firebaseSource.signOut()
                            completion(error)
                        }
                    }
                }

            case .failure(let error):
                completion(error)
            }
        }
    }

    func signOut(completion: @escaping () -> Void) {
        guard let token = tokenRepository.loadToken() else {
            firebaseSource.signOut()
            completion()
            return
        }

        apiSource.signOutCustomer(token: token) {
            self.firebaseSource.signOut()
            self.tokenRepository.deleteToken()
            completion()
        }
    }

    func getCurrentUser() -> User? {
        guard let user = firebaseSource.getCurrentUser() else { return nil }
        return User.from(firebaseUser: user, customer: nil)
    }
}
