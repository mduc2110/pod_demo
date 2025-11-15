public final class ResultResolver {

    public init() {}

    public func resolve<T>(
        _ block: () async throws -> T
    ) async -> Result<T> {
        do {
            return Result.Success(try await block())
        } catch {
            return Result.Failure(error)
        }
    }
}
