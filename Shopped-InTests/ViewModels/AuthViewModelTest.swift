//
//  AuthViewModelTest.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 26/06/2025.
//
import XCTest
import Combine
import UIKit
@testable import Shopped_In

fileprivate class StubSignUpUseCase: SignUpUseCase {
    var executeCalled = false
    var receivedUser: User?
    var receivedPassword: String?
    var errorToReturn: Error?

    init(error: Error? = nil) {
        self.errorToReturn = error
    }

    func execute(user: User, password: String, completion: @escaping (Error?) -> Void) {
        executeCalled = true
        receivedUser = user
        receivedPassword = password
        completion(errorToReturn)
    }
}

fileprivate class StubSignInUseCase: SignInUseCase {
    var executeCalled = false
    var receivedEmail: String?
    var receivedPassword: String?
    var errorToReturn: Error?

    init(error: Error? = nil) {
        self.errorToReturn = error
    }

    func execute(email: String, password: String, completion: @escaping (Error?) -> Void) {
        executeCalled = true
        receivedEmail = email
        receivedPassword = password
        completion(errorToReturn)
    }
}

fileprivate class StubSignInWithGoogleUseCase: SignInWithGoogleUseCase {
    var executeCalled = false
    var receivedViewController: UIViewController?
    var errorToReturn: Error?

    init(error: Error? = nil) {
        self.errorToReturn = error
    }

    func execute(presentingViewController: UIViewController, completion: @escaping (Error?) -> Void) {
        executeCalled = true
        receivedViewController = presentingViewController
        completion(errorToReturn)
    }
}

fileprivate class StubSignOutUseCase: SignOutUseCase {
    var executeCalled = false

    func execute(completion: @escaping () -> Void) {
        executeCalled = true
        completion()
    }
}

fileprivate class StubGetCurrentUserUseCase: GetCurrentUserUseCase {
    var userToReturn: User?

    init(user: User?) {
        self.userToReturn = user
    }

    func execute() -> AnyPublisher<User?, Never> {
        Just(userToReturn)
            .eraseToAnyPublisher()
    }
}

final class AuthViewModelTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()

        let validEmail = "test@example.com"
    let validPassword = "123456"
    let validPhone = "1234567890"
    let firstName = "John"
    let lastName = "Doe"

    private func makeViewModel(
        signUpError: Error? = nil,
        signInError: Error? = nil,
        signInGoogleError: Error? = nil,
        currentUser: User? = nil
    ) -> (
        vm: AuthViewModel,
        signUp: StubSignUpUseCase,
        signIn: StubSignInUseCase,
        google: StubSignInWithGoogleUseCase,
        signOut: StubSignOutUseCase,
        getCurrent: StubGetCurrentUserUseCase
    ) {
        let signUp = StubSignUpUseCase(error: signUpError)
        let signIn = StubSignInUseCase(error: signInError)
        let google = StubSignInWithGoogleUseCase(error: signInGoogleError)
        let signOut = StubSignOutUseCase()
        let getCurrent = StubGetCurrentUserUseCase(user: currentUser)
        let vm = AuthViewModel(
            signUpUseCase: signUp,
            signInUseCase: signIn,
            getCurrentUserUseCase: getCurrent,
            signOutUseCase: signOut,
            signInwithGoogleUseCase: google
        )
        return (vm, signUp, signIn, google, signOut, getCurrent)
    }

    func testSignUp_success() {
        let (vm, stubSignUp, _, _, _, _) = makeViewModel(signUpError: nil)
        vm.email = validEmail
        vm.password = validPassword
        vm.phone = validPhone
        vm.firstName = firstName
        vm.lastName = lastName

        vm.signUp()

        XCTAssertTrue(stubSignUp.executeCalled)
        XCTAssertEqual(stubSignUp.receivedPassword, validPassword)
        XCTAssertTrue(vm.isAuthenticated)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
    }

    func testSignUp_error() {
        let (vm, stubSignUp, _, _, _, _) = makeViewModel(signUpError: TestError.sampleError)
        vm.email = validEmail
        vm.password = validPassword
        vm.phone = validPhone
        vm.firstName = firstName
        vm.lastName = lastName

        vm.signUp()

        XCTAssertTrue(stubSignUp.executeCalled)
        XCTAssertEqual(vm.errorMessage, TestError.sampleError.localizedDescription)
        XCTAssertFalse(vm.isAuthenticated)
        XCTAssertFalse(vm.isLoading)
    }

    func testSignIn_success() {
        let (vm, _, stubSignIn, _, _, _) = makeViewModel(signInError: nil)
        vm.email = validEmail
        vm.password = validPassword

        vm.signIn()

        XCTAssertTrue(stubSignIn.executeCalled)
        XCTAssertTrue(vm.isAuthenticated)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
    }

    func testSignIn_error() {
        let (vm, _, stubSignIn, _, _, _) = makeViewModel(signInError: TestError.sampleError)
        vm.email = validEmail
        vm.password = validPassword

        vm.signIn()

        XCTAssertTrue(stubSignIn.executeCalled)
        XCTAssertEqual(vm.errorMessage, TestError.sampleError.localizedDescription)
        XCTAssertFalse(vm.isAuthenticated)
        XCTAssertFalse(vm.isLoading)
    }

    func testContinueAsGuest() {
        let (vm, _, _, _, _, _) = makeViewModel()
        vm.continueAsGuest()
        XCTAssertTrue(vm.isGuest)
        XCTAssertFalse(vm.isAuthenticated)
    }

    func testSignOut() {
        let (vm, _, _, _, stubSignOut, _) = makeViewModel()
        vm.isAuthenticated = true

        vm.signOut()

        XCTAssertTrue(stubSignOut.executeCalled)
        XCTAssertFalse(vm.isAuthenticated)
        XCTAssertFalse(vm.isLoading)
    }

    func testSignInWithGoogle_success() {
        let vc = UIViewController()
        let (vm, _, _, stubGoogle, _, _) = makeViewModel(signInGoogleError: nil)
        let exp = expectation(description: "Google sign-in success")
        vm.$isAuthenticated
            .dropFirst()
            .sink { _ in exp.fulfill() }
            .store(in: &cancellables)

        vm.signInWithGoogle(presentingViewController: vc)
        waitForExpectations(timeout: 1)

        XCTAssertTrue(stubGoogle.executeCalled)
        XCTAssertTrue(vm.isAuthenticated)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
        XCTAssertEqual(stubGoogle.receivedViewController, vc)
    }

    func testSignInWithGoogle_error() {
        let vc = UIViewController()
        let (vm, _, _, stubGoogle, _, _) = makeViewModel(signInGoogleError: TestError.sampleError)
        let exp = expectation(description: "Google sign-in error")
        vm.$errorMessage
            .dropFirst()
            .sink { _ in exp.fulfill() }
            .store(in: &cancellables)

        vm.signInWithGoogle(presentingViewController: vc)
        waitForExpectations(timeout: 1)

        XCTAssertTrue(stubGoogle.executeCalled)
        XCTAssertEqual(vm.errorMessage, TestError.sampleError.localizedDescription)
        XCTAssertFalse(vm.isAuthenticated)
        XCTAssertFalse(vm.isLoading)
        XCTAssertEqual(stubGoogle.receivedViewController, vc)
    }
}
