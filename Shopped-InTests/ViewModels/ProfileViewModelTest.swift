//
//  ProfileViewModelTest.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 26/06/2025.
//
import XCTest
import Combine
@testable import Shopped_In

fileprivate class StubGetCurrentUserUseCase: GetCurrentUserUseCase {
    private(set) var executeCalled = false
    let subject = PassthroughSubject<User?, Never>()
    
    func execute() -> AnyPublisher<User?, Never> {
        executeCalled = true
        return subject.eraseToAnyPublisher()
    }
}

fileprivate class StubSignOutUseCase: SignOutUseCase {
    private(set) var executeCalled = false
    
    func execute(completion: @escaping () -> Void) {
        executeCalled = true
        completion()
    }
}

fileprivate class StubDeleteCartUseCase: DeleteCartUseCase {
    private(set) var executeCalled = false
    
    func execute() {
        executeCalled = true
    }
}

final class ProfileViewModelTests: XCTestCase {
    private var viewModel: ProfileViewModel!
    private var getCurrentUserUseCase: StubGetCurrentUserUseCase!
    private var signOutUseCase: StubSignOutUseCase!
    private var deleteCartUseCase: StubDeleteCartUseCase!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        getCurrentUserUseCase = StubGetCurrentUserUseCase()
        signOutUseCase = StubSignOutUseCase()
        deleteCartUseCase = StubDeleteCartUseCase()
        viewModel = ProfileViewModel(
            getCurrentUserUseCase: getCurrentUserUseCase,
            signOut: signOutUseCase,
            deleteCartUseCase: deleteCartUseCase
        )
        cancellables = []
    }
    
    override func tearDown() {
        cancellables = nil
        viewModel = nil
        deleteCartUseCase = nil
        signOutUseCase = nil
        getCurrentUserUseCase = nil
        super.tearDown()
    }
    
    func testLoad_publishesUserAndCallsUseCase() {
        let expectedUser = User(
            email: "test@example.com",
            phone: "1234567890",
            firstName: "Test",
            lastName: "User",
            customerID: "cust123",
            isVerified: true
        )
        var publishedUser: User?
        let exp = expectation(description: "user published")
        
        viewModel.$user
            .dropFirst()
            .sink { user in
                publishedUser = user
                exp.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.load()
        XCTAssertTrue(getCurrentUserUseCase.executeCalled, "Expected execute() to be called")
        getCurrentUserUseCase.subject.send(expectedUser)
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(publishedUser?.firstName, expectedUser.firstName)
    }
    
    func testSignOutUser_callsSignOut_thenDeletesCart_thenCallsCompletion() {
        var completionCalled = false
        
        viewModel.signOutUser {
            completionCalled = true
        }
        
        XCTAssertTrue(signOutUseCase.executeCalled, "Expected signOut.execute() to be called")
        XCTAssertTrue(deleteCartUseCase.executeCalled, "Expected deleteCart.execute() to be called")
        XCTAssertTrue(completionCalled, "Expected completion handler to be invoked")
    }
}
