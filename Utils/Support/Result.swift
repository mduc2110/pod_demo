import Foundation

public enum Result<T>: @unchecked Sendable {
    case Success(T)
    case Failure(Error)
}
