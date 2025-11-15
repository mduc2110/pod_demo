public final class AppDependencies {
    // Modules
    nonisolated(unsafe) internal static var commonModule: CommonModule!
    nonisolated(unsafe) internal static var dataModule: DataModule!
    nonisolated(unsafe) internal static var domainModule: DomainModule!

    static func getFileStoreManager() -> FileStoreManager {
        commonModule.provideFileStoreManager()
    }

    static func getDataPortProvider() -> DataPortProvider {
        commonModule.provideDataPortProvider()
    }
}
