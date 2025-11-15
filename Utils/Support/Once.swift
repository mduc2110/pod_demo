public class Once<T> {
    private var value: T?

    public init(_ value: T? = nil) {
        self.value = value
    }

    public func get() -> T? {
        if let currentValue = value {
            let result = currentValue
            value = nil
            return result
        }
        return nil
    }
}
