//
//  AuthAssembly.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 20/06/2025.
//

import Swinject

class AuthAssembly: Assembly {
    func assemble(container: Container) {
        container.register(APIAuthRemoteDataSource.self) { r in
            APIAuthRemoteDataSourceImpl(
                service: r.resolve(BuyAPIService.self)!
            )
        }.inObjectScope(.container)
        
        container.register(FireBaseAuthRemoteDataSource.self) { _ in
            FireBaseAuthRemoteDataSourceImpl()
        }.inObjectScope(.container)
        
        container.register(AuthRepository.self) { r in
            AuthRepositoryImpl(
                tokenRepository: r.resolve(TokenRepo.self)!,
                apiSource: r.resolve(APIAuthRemoteDataSource.self)!,
                firebaseSource: r.resolve(FireBaseAuthRemoteDataSource.self)!
            )
        }.inObjectScope(.container)
        
        container.register(AutomaticSignInUseCase.self) { r in
            AutomaticSignInUseCaseImpl(authRepo: r.resolve(AuthRepository.self)!)
        }.inObjectScope(.graph)

        container.register(GetCurrentUserUseCase.self) { r in
            GetCurrentUserUseCaseImpl(authRepository: r.resolve(AuthRepository.self)!)
        }.inObjectScope(.graph)

        container.register(SignInUseCase.self) { r in
            SignInUseCaseImpl(authRepository: r.resolve(AuthRepository.self)!)
        }.inObjectScope(.graph)

        container.register(SignInWithGoogleUseCase.self) { r in
            SignInWithGoogleUseCaseImpl(authRepository: r.resolve(AuthRepository.self)!)
        }.inObjectScope(.graph)

        container.register(SignOutUseCase.self) { r in
            SignOutUseCaseImpl(authRepository: r.resolve(AuthRepository.self)!)
        }.inObjectScope(.graph)

        container.register(SignUpUseCase.self) { r in
            SignUpUseCaseImpl(authRepository: r.resolve(AuthRepository.self)!)
        }.inObjectScope(.graph)
        
        container.register(ResendVerificationEmailUseCase.self) { r in
            ResendVerificationEmailUseCaseImpl(repo: r.resolve(AuthRepository.self)!)
        }.inObjectScope(.graph)
        
        container.register(ReloadUserUseCase.self) { r in
            ReloadUserUseCaseImpl(repo: r.resolve(AuthRepository.self)!)
        }.inObjectScope(.graph)
        
        container.register(AuthViewModel.self) { r in
            AuthViewModel(
                  signUpUseCase: r.resolve(SignUpUseCase.self)!, 
                  signInUseCase: r.resolve(SignInUseCase.self)!, 
                  getCurrentUserUseCase: r.resolve(GetCurrentUserUseCase.self)!, 
                  signOutUseCase: r.resolve(SignOutUseCase.self)!, 
                  signInwithGoogleUseCase: r.resolve(SignInWithGoogleUseCase.self)!
            )
        }.inObjectScope(.transient)
        
        container.register(SplashViewModel.self) { r in
            SplashViewModel(automaticSignInUseCase: r.resolve(AutomaticSignInUseCase.self)!)
        }
    }
}
