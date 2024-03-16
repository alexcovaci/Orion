import Foundation


@propertyWrapper
struct Injected<T> {
    private var _value: T?
    private var container: DependencyContainer?
    
    var wrappedValue: T {
        mutating get {
            if let value = _value {
                return value
            } else {
                guard let container else {
                    fatalError("Dependency container has not been set.")
                }
                let resolved = container.resolve(T.self)
                _value = resolved
                return resolved
            }
        }
        set { 
            _value = newValue
        }
    }
    
    
    init() {
    }
    
    init(container: DependencyContainer) {
        self.container = container
    }
    
    mutating func setContainer(_ container: DependencyContainer) {
        self.container = container
    }
}
