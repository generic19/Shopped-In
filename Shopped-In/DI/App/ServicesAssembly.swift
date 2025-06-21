//
//  ServicesAssembly.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 20/06/2025.
//
import Swinject

class ServicesAssembly: Assembly {
    func assemble(container: Container) {
        container.register(AlamofireAPIService.self) { _ in
            AlamofireAPIService()
        }.inObjectScope(.container)
        
        container.register(BuyAPIService.self) { _ in
            BuyAPIService()
        }.inObjectScope(.container)
    }
}
