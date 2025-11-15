public class CommonModule: DependencyModule {
    // Materials exist from App
    private let fileStoreManager: FileStoreManager
    private let dataPortProvider: DataPortProvider

    // Construct
    init(
        fileStoreManager: FileStoreManager,
        dataPortProvider: DataPortProvider,
    ) {
        self.fileStoreManager = fileStoreManager
        self.dataPortProvider = dataPortProvider
    }

    // Attach to Dependency Graph
    public func install() {
        AppDependencies.commonModule = self
    }

    // Provide components
    internal func provideResultResolver() -> ResultResolver {
        ResultResolver()
    }

    internal func provideFileStoreManager() -> FileStoreManager {
        fileStoreManager
    }

    func provideDataPortProvider() -> DataPortProvider {
        dataPortProvider
    }
}
