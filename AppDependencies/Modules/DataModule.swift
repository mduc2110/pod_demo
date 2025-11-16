import Foundation
import Alamofire

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

    internal func getProcessorFactory() -> ApiProcessorFactory {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData

        return ApiProcessorFactory(
            session: Session(configuration: configuration),
            responseInterceptor: provideApiResponseInterceptor(),
        )
    }
    // Provide components
    internal func provideApiResponseInterceptor() -> ApiResponseInterceptor {
        apiResponseInterceptor
    }
    
    
    func getMeshService() -> MeshService {
        return MeshService(url: baseURL, factory: getProcessorFactory())
    }
}
