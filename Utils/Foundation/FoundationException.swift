public protocol Exception: Error {
    var message: String { get }
    var happenFunction: String { get }
    var happenFile: String { get }
    var happenLine: UInt { get }
}

public struct NilException: Exception {
    public var message: String

    public var happenFile: String

    public var happenFunction: String

    public var happenLine: UInt

    public init(
        _ message: String,
        _ happenFunction: String = #function,
        _ happenFile: String = #file,
        _ happenLine: UInt = #line
    ) {
        self.message = message
        self.happenFunction = happenFunction
        self.happenFile = happenFile
        self.happenLine = happenLine
    }
}
