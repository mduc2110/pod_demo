extension Optional {
    @discardableResult
    public func require(
        callFunction: String = #function,
        callFile: String = #file,
        callLine: UInt = #line
    ) throws -> Wrapped {
        switch self {
        case .some(let wrapped):
            return wrapped
        case .none:
            throw NilException(
                "Value is required.",
                callFunction,
                callFile,
                callLine,
            )
        }
    }
}
