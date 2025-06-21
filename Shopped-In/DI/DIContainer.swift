
import Swinject

class DIContainer {
    static let shared = DIContainer()
    
    private let container = Container()
    
    private init() {
        registerAssemblies()
    }
    
    func resolve<Resolved>() -> Resolved {
        guard let resolved = container.resolve(Resolved.self) else {
            fatalError("Could not resolve dependency of type \(Resolved.self).")
        }
        return resolved
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
            SettingsAssembly(),
        ]
        
        assemblies.forEach { $0.assemble(container: container) }
    }
}
