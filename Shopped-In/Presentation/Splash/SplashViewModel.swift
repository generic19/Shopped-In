//
//  SplashViewModel.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 19/06/2025.
//
import Combine
import Foundation

class SplashViewModel: ObservableObject {
    private let automaticSignInUseCase: AutomaticSignInUseCase
    
    @Published var destination: SwitchRoute?
    
    private var group = DispatchGroup()
    private var signInSuccess: Bool?
    
    init(automaticSignInUseCase: AutomaticSignInUseCase) {
        self.automaticSignInUseCase = automaticSignInUseCase
    }
    
    func splashStarted() {
        destination = nil
        signInSuccess = nil
        
        group.enter()
        group.enter()
        
        group.notify(queue: DispatchQueue.main) {
            if let success = self.signInSuccess {
                self.destination = success ? .mainTabs : .authentication
            }
        }
        
        automaticSignInUseCase.execute { success in
            self.signInSuccess = success
            self.group.leave()
        }
    }
    
    func splashEnded() {
        group.leave()
    }
}
