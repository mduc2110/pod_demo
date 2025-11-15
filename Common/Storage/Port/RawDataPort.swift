import Foundation

public final class RawDataPort: DataPort {
    private let fileUrl: URL
    
    init(fileUrl: URL) {
        self.fileUrl = fileUrl
    }
    
    public var meta: String { fileUrl.path }
    
    public func pull() throws -> Data {
        do {
            return try Data(contentsOf: fileUrl)
        } catch {
            Logger.e(
                "RawDataPort[\(fileUrl)]",
                "Pull() failed by \(error.getExceptionMessage())",
            )
            throw error
        }
    }
    
    public func push(data: Data) throws {
        do {
            try data.write(to: fileUrl)
        } catch {
            Logger.e(
                "RawDataPort[\(fileUrl)]",
                "Push() failed by \(error.getExceptionMessage())",
            )
            throw error
        }
    }
}
