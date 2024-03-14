import Foundation


protocol Coordinator {
    var dependencyContainer: DependencyContainer { get }
    init(dependencyContainer: DependencyContainer)
}
