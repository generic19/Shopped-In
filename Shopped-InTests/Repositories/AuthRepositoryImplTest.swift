//
//  AuthRepositoryImplTest.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 26/06/2025.
//
import XCTest
import Combine
import UIKit
@testable import Shopped_In

fileprivate struct FakeFirebaseUser: FirebaseUser {
  let email: String?
  let displayName: String?
  let isEmailVerified: Bool
}

fileprivate class MockTokenRepo: TokenRepo {
    private(set) var savedToken: String?
    var loadTokenReturn: String? = nil
    private(set) var deleteCalled = false

    func saveToken(_ token: String) { savedToken = token }
    func loadToken() -> String? { loadTokenReturn }
    func deleteToken() { deleteCalled = true }
}

fileprivate class MockAPIAuthRemoteDataSource: APIAuthRemoteDataSource {
    // signInCustomer
    var signInResultQueue: [Result<CustomerAccessToken, Error>] = []
    private(set) var signInCalls: [(email: String, password: String)] = []

    // createCustomer
    var createResultQueue: [Error?] = []
    private(set) var createCalls: [(user: Shopped_In.User, password: String)] = []

    // getCustomer
    var getCustomerResultQueue: [Result<Shopped_In.User, Error>] = []
    private(set) var getCustomerTokens: [String] = []

    // signOutCustomer
    private(set) var signOutCalled = false
    private(set) var signOutToken: String?

    func createCustomer(user: Shopped_In.User, password: String, completion: @escaping (Error?) -> Void) {
        createCalls.append((user, password))
        completion(createResultQueue.removeFirst())
    }

    func signInCustomer(email: String, password: String, completion: @escaping (Result<CustomerAccessToken, Error>) -> Void) {
        signInCalls.append((email, password))
        completion(signInResultQueue.removeFirst())
    }

    func signOutCustomer(token: String, completion: @escaping () -> Void) {
        signOutCalled = true
        signOutToken = token
        completion()
    }

    func getCustomer(token: String, completion: @escaping (Result<Shopped_In.User, Error>) -> Void) {
        getCustomerTokens.append(token)
        completion(getCustomerResultQueue.removeFirst())
    }
}

fileprivate class MockFirebaseAuthRemoteDataSource: FireBaseAuthRemoteDataSource {
    // signIn
    var signInResultQueue: [Result<UserDTO, Error>] = []
    private(set) var signInCalls: [(email: String, password: String)] = []

    // signUp
    var signUpResultQueue: [Result<UserDTO, Error>] = []
    private(set) var signUpCalls: [(user: Shopped_In.User, password: String)] = []

    private(set) var rollbackCalled = false

    // Google
    var googleResultQueue: [Result<UserDTO, Error>] = []
    private(set) var googleCalls: [UIViewController] = []

    // getUserDTO
    var getUserDTOResultQueue: [Result<UserDTO, Error>] = []
    private(set) var getUserDTOCalled = false

    // reloadUser
    var reloadUserResultQueue: [UserDTO?] = []
    private(set) var reloadUserCalled = false

    // sendEmailVerification / signOut
    private(set) var sendEmailVerificationCalled = false
    private(set) var signOutCalled = false

    func signIn(email: String, password: String, completion: @escaping (Result<UserDTO, Error>) -> Void) {
        signInCalls.append((email, password))
        completion(signInResultQueue.removeFirst())
    }

    func signUp(user: Shopped_In.User, password: String, completion: @escaping (Result<UserDTO, Error>) -> Void) {
        signUpCalls.append((user, password))
        completion(signUpResultQueue.removeFirst())
    }

    func rollbackSignUp(completion: @escaping () -> Void) {
        rollbackCalled = true
        completion()
    }

    func signOut() {
        signOutCalled = true
    }

    func signInWithGoogle(presentingViewController: UIViewController,
                          completion: @escaping (Result<UserDTO, Error>) -> Void) {
        googleCalls.append(presentingViewController)
        completion(googleResultQueue.removeFirst())
    }

    func sendEmailVerification() {
        sendEmailVerificationCalled = true
    }

    func getCurrentUser() -> FirebaseUser? { nil }

    func getUserDTO(completion: @escaping (Result<UserDTO, Error>) -> Void) {
        getUserDTOCalled = true
        completion(getUserDTOResultQueue.removeFirst())
    }

    func reloadUser(completion: @escaping (UserDTO?) -> Void) {
        reloadUserCalled = true
        completion(reloadUserResultQueue.removeFirst())
    }
}

// MARK: - Tests

class AuthRepositoryImplTests: XCTestCase {
    fileprivate var firebaseSource: MockFirebaseAuthRemoteDataSource!
    fileprivate var apiSource: MockAPIAuthRemoteDataSource!
    fileprivate var tokenRepo: MockTokenRepo!
    
    var sut: AuthRepositoryImpl!
    var subs = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        tokenRepo = MockTokenRepo()
        apiSource = MockAPIAuthRemoteDataSource()
        firebaseSource = MockFirebaseAuthRemoteDataSource()
        sut = AuthRepositoryImpl(
            tokenRepository: tokenRepo,
            apiSource: apiSource,
            firebaseSource: firebaseSource
        )
    }

    override func tearDown() {
        subs.removeAll()
        super.tearDown()
    }

    // MARK: signOut

    func test_signOut_noToken_callsFirebaseOnly_andClearsUser() {
        tokenRepo.loadTokenReturn = nil
        let exp = expectation(description: "signOut completion")

        var lastUser: Shopped_In.User?
        sut.currentUser
            .sink { lastUser = $0 }
            .store(in: &subs)

        sut.signOut {
            exp.fulfill()
        }

        waitForExpectations(timeout: 0.5)
        XCTAssertTrue(firebaseSource.signOutCalled)
        XCTAssertFalse(apiSource.signOutCalled)
        XCTAssertNil(lastUser)
    }

    func test_signOut_withToken_callsApi_thenFirebase_thenDelete_andClears() {
        tokenRepo.loadTokenReturn = "tok"
        let exp = expectation(description: "signOut completion")

        sut.currentUser
            .sink { _ in }
            .store(in: &subs)

        sut.signOut {
            exp.fulfill()
        }

        waitForExpectations(timeout: 0.5)
        XCTAssertTrue(apiSource.signOutCalled)
        XCTAssertEqual(apiSource.signOutToken, "tok")
        XCTAssertTrue(firebaseSource.signOutCalled)
        XCTAssertTrue(tokenRepo.deleteCalled)
    }

    // MARK: resendVerificationEmail

    func test_resendVerificationEmail_delegatesToFirebase() {
        sut.resendVerificationEmail()
        XCTAssertTrue(firebaseSource.sendEmailVerificationCalled)
    }

    // MARK: signInWithGoogle

    func test_signInWithGoogle_success_savesToken_andCallsCompletionNil() {
        let vc = UIViewController()
        // Firebase returns a DTO
        let fakeUser = UserDTO(firebaseUser: FakeFirebaseUser(email: "a@b.com", displayName: "name", isEmailVerified: true),
                               randomToken: "rt")
        firebaseSource.googleResultQueue = [.success(fakeUser)]
        // API signInCustomer succeeds
        apiSource.signInResultQueue = [.success("token123")]

        let exp = expectation(description: "google completion")
        sut.signInWithGoogle(presentingViewController: vc) { err in
            XCTAssertNil(err)
            exp.fulfill()
        }

        waitForExpectations(timeout: 0.5)
        XCTAssertEqual(tokenRepo.savedToken, "token123")
    }

    func test_signInWithGoogle_firebaseFails_callsCompletionWithError() {
        firebaseSource.googleResultQueue = [.failure(TestError.sampleError)]
        let exp = expectation(description: "google failure")
        sut.signInWithGoogle(presentingViewController: UIViewController()) { err in
            XCTAssertEqual(err as? TestError, TestError.sampleError)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.5)
    }

    // MARK: signIn

    func test_signIn_success_triggersSignInCustomer_andPublishesUser() {
        let dto = UserDTO(firebaseUser: FakeFirebaseUser(email: "x@y.com", displayName: "name", isEmailVerified: false),
                          randomToken: "tok")
        firebaseSource.signInResultQueue = [.success(dto)]
        // next, api signInCustomer
        apiSource.signInResultQueue = [.success("tkn")]
        // then getCustomer
        let user = User(email: "x@y.com", phone: nil, firstName: "X", lastName: "Y", customerID: "cid")
        apiSource.getCustomerResultQueue = [.success(user)]

        var receivedUser: User?
        let exp = expectation(description: "signIn complete")
        sut.currentUser
            .dropFirst()
            .sink { receivedUser = $0 }
            .store(in: &subs)

        sut.signIn(email: "x@y.com", password: "pw") { err in
            XCTAssertNil(err)
            exp.fulfill()
        }

        waitForExpectations(timeout: 0.5)
        XCTAssertEqual(tokenRepo.savedToken, "tkn")
        XCTAssertEqual(receivedUser?.email, "x@y.com")
        XCTAssertFalse(receivedUser!.isVerified)
    }

    func test_signIn_firebaseFails_callsCompletionWithError() {
        firebaseSource.signInResultQueue = [.failure(TestError.sampleError)]
        let exp = expectation(description: "signIn failure")
        sut.signIn(email: "e", password: "p") { err in
            XCTAssertEqual(err as? TestError, TestError.sampleError)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.5)
        XCTAssertTrue(apiSource.signInCalls.isEmpty)
    }

    // MARK: signUp

    func test_signUp_success_savesToken_setsCurrentUser_andSendsVerificationIfNeeded() {
        let newUser = User(email: "n@u.com", phone: nil, firstName: "N", lastName: "U", customerID: nil)
        let dto = UserDTO(firebaseUser: FakeFirebaseUser(email: "n@u.com", displayName: "name", isEmailVerified: false),
                          randomToken: "rt")
        firebaseSource.signUpResultQueue = [.success(dto)]
        apiSource.createResultQueue = [nil]
        apiSource.signInResultQueue = [.success("nnn")]
        let createdUser = User(email: "n@u.com", phone: nil, firstName: "N", lastName: "U", customerID: "newid")
        apiSource.getCustomerResultQueue = [.success(createdUser)]

        var recv: User?
        sut.currentUser
            .dropFirst()
            .sink { recv = $0 }
            .store(in: &subs)

        let exp = expectation(description: "signUp complete")
        sut.signUp(user: newUser, password: "pw") { err in
            XCTAssertNil(err)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.5)

        XCTAssertEqual(tokenRepo.savedToken, "nnn")
        XCTAssertEqual(recv?.customerID, "newid")
        XCTAssertTrue(firebaseSource.sendEmailVerificationCalled)
    }

    func test_signUp_createCustomerFails_rollsBack_andCallsCompletionWithError() {
        let newUser = User(email: "u@u.com", phone: nil, firstName: "U", lastName: "U", customerID: nil)
        let dto = UserDTO(firebaseUser: FakeFirebaseUser(email: "u@u.com", displayName: "name", isEmailVerified: true),
                          randomToken: "t")
        firebaseSource.signUpResultQueue = [.success(dto)]
        apiSource.createResultQueue = [TestError.sampleError]

        let exp = expectation(description: "signUp rollback")
        sut.signUp(user: newUser, password: "pw") { err in
            XCTAssertEqual(err as? TestError, TestError.sampleError)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.5)
        XCTAssertTrue(firebaseSource.rollbackCalled)
        XCTAssertNil(tokenRepo.savedToken)
    }

    // MARK: automaticSignIn

    func test_automaticSignIn_success_savesAndPublishesUser_andReturnsTrue() {
        let dto = UserDTO(firebaseUser: FakeFirebaseUser(email: "a@b.c", displayName: "name", isEmailVerified: true),
                          randomToken: "rt")
        firebaseSource.getUserDTOResultQueue = [.success(dto)]
        apiSource.signInResultQueue = [.success("tok")]
        let user = User(email: "a@b.c", phone: nil, firstName: "First", lastName: "Last", customerID: "cid")
        apiSource.getCustomerResultQueue = [.success(user)]

        var published: User?
        sut.currentUser
            .dropFirst()
            .sink { published = $0 }
            .store(in: &subs)

        let exp = expectation(description: "autoSignIn")
        sut.automaticSignIn { success in
            XCTAssertTrue(success)
            exp.fulfill()
        }

        waitForExpectations(timeout: 0.5)
        XCTAssertEqual(tokenRepo.savedToken, "tok")
        XCTAssertEqual(published?.customerID, "cid")
    }

    func test_automaticSignIn_noFirebaseDTO_andNoToken_returnsFalse() {
        firebaseSource.getUserDTOResultQueue = [.failure(TestError.sampleError)]
        tokenRepo.loadTokenReturn = nil

        let exp = expectation(description: "autoSignIn-fail")
        sut.automaticSignIn { success in
            XCTAssertFalse(success)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.5)
    }
}
