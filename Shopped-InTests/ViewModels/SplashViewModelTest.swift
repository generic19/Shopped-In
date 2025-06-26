//
//  SplashViewModelTest.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 26/06/2025.
//
import XCTest
import Combine
@testable import Shopped_In

fileprivate class StubAutomaticSignInUseCase: AutomaticSignInUseCase {
    private let result: Bool
    fileprivate(set) var executeCalled = false

    init(result: Bool) {
        self.result = result
    }

    func execute(completion: @escaping (Bool) -> Void) {
        executeCalled = true
        completion(result)
    }
}

final class SplashViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func testExecuteCalledWhenSplashStarted() {
        let stub = StubAutomaticSignInUseCase(result: true)
        let vm = SplashViewModel(automaticSignInUseCase: stub)

        XCTAssertFalse(stub.executeCalled, "execute() should not have been called before splashStarted()")
        vm.splashStarted()
        XCTAssertTrue(stub.executeCalled, "execute() should be called when splashStarted() is invoked")
    }

    func testDestinationIsMainTabsOnSignInSuccess() {
        let stub = StubAutomaticSignInUseCase(result: true)
        let vm = SplashViewModel(automaticSignInUseCase: stub)

        let exp = expectation(description: "Should route to .mainTabs on success")
        vm.$destination
            .dropFirst()
            .sink { route in
                if route == .mainTabs {
                    exp.fulfill()
                }
            }
            .store(in: &cancellables)

        vm.splashStarted()
        vm.splashEnded()

        wait(for: [exp], timeout: 1.0)
    }

    func testDestinationIsOnboardingOnSignInFailure() {
        let stub = StubAutomaticSignInUseCase(result: false)
        let vm = SplashViewModel(automaticSignInUseCase: stub)

        let exp = expectation(description: "Should route to .onboarding on failure")
        vm.$destination
            .dropFirst()
            .sink { route in
                if route == .onboarding {
                    exp.fulfill()
                }
            }
            .store(in: &cancellables)

        vm.splashStarted()
        vm.splashEnded()

        wait(for: [exp], timeout: 1.0)
    }
}
