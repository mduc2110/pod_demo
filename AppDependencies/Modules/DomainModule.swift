public class DomainModule: DependencyModule {
    // Attach to Dependency Graph
    public func install() {
        AppDependencies.domainModule = self
    }

    // Provides components
}
