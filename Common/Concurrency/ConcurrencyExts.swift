import Foundation

public func delay(_ miliSecs: TimeInterval) async throws {
    try await Task.sleep(nanoseconds: UInt64(miliSecs * 1_000_000))
}

public func syncOnMain<T>(_ block: @escaping () -> T) -> T {
    if Thread.isMainThread {
        return block()
    } else {
        return DispatchQueue.main.sync {
            block()
        }
    }
}
