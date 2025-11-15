import Foundation

public class DataModule: DependencyModule {

    // Materials exist from App
    private let baseURL: String

    // Construct
    public init(baseURL: String) {
        self.baseURL = baseURL
    }

    private lazy var apiResponseInterceptor = PodApiResponseInterceptor()

    // Attach to Dependency Graph
    public func install() {
        AppDependencies.dataModule = self
    }

    // Provide components
    internal func provideApiResponseInterceptor() -> ApiResponseInterceptor {
        apiResponseInterceptor
    }
}
