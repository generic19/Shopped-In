//
//  ProfileAssembly.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 26/06/2025.
//
import Swinject

class ProfileAssembly: Assembly {
    func assemble(container: Container) {
        container.register(ProfileViewModel.self) { r in
            ProfileViewModel(
                getCurrentUserUseCase: r.resolve(GetCurrentUserUseCase.self)!,
                signOut: r.resolve(SignOutUseCase.self)!,
                deleteCartUseCase: r.resolve(DeleteCartUseCase.self)!,
            )
        }
    }
}
