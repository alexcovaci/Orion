import Foundation


class DependencyContainer {
    private var services: [String: Any] = [:]

    func register<T>(service: T) {
        let key = String(describing: T.self)
        services[key] = service
    }

    func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: T.self)
        guard let service = services[key] as? T else {
            fatalError("No registered service for type \(T.self)")
        }
        return service
    }
}
