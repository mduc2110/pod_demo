public protocol AppException: Exception {}

// UnAuthenticated Exceptions
public struct AppUnauthenticatedException: AppException {
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

// Service Exception
public struct AppServiceException: AppException {
    public let errorCode: Int

    public var message: String

    public var happenFunction: String

    public var happenFile: String

    public var happenLine: UInt

    public init(
        _ errorCode: Int,
        _ errorMessage: String,
        _ happenFunction: String = #function,
        _ happenFile: String = #file,
        _ happenLine: UInt = #line
    ) {
        self.errorCode = errorCode
        self.message = "[\(errorCode)]: \(errorMessage)"
        self.happenFunction = happenFunction
        self.happenFile = happenFile
        self.happenLine = happenLine
    }
}

// Common Exceptions
public struct AppIllegalException: AppException {
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

public struct AppRuntimeException: AppException {
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
