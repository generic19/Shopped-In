
import Swinject

class DIContainer {
    static let shared = DIContainer()
    
    private let container = Container()
    
    private init() {
        registerAssemblies()
    }
    
    func resolve<Resolved>() -> Resolved {
        return container.resolve(Resolved.self)!
    }
    
    private func registerAssemblies() {
        let assemblies: [Assembly] = [
            ServicesAssembly(),
            AddressAssembly(),
            AuthAssembly(),
            BrandAssembly(),
            CartAssembly(),
            OrderAssembly(),
            ProductAssembly(),
            TokenAssembly(),
        ]
        
        assemblies.forEach { $0.assemble(container: container) }
    }
}
