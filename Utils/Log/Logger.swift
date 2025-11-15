import Foundation

public protocol LogPrinter {
    func i(_ tag: String, _ msg: String)
    func d(_ tag: String, _ msg: String)
    func w(_ tag: String, _ msg: String)
    func w(_ tag: String, _ msg: String, _ exception: Exception)
    func e(_ tag: String, _ msg: String)
    func e(_ tag: String, _ msg: String, _ exception: Exception)
}

private class DefaultLogPrinter: LogPrinter {
    private var time: Date {
        return Date()
    }

    func i(_ tag: String, _ msg: String) {
        print("\(time) ~ [INFO | \(tag)]: \(msg)")
    }

    func d(_ tag: String, _ msg: String) {
        print("\(time) ~ [DEBUG | \(tag)]: \(msg)")
    }

    func w(_ tag: String, _ msg: String) {
        print("\(time) ~ [WARN | \(tag)]: \(msg)")
    }

    func w(_ tag: String, _ msg: String, _ exception: Exception) {
        print(
            "\(time) ~ [WARN | \(tag)]: \(msg)\n"
                + "Happen in \(exception.happenFile):\(exception.happenLine)\n"
                + "Method: \(exception.happenFunction)\n"
                + "Message: \(exception.message)"
        )
    }

    func e(_ tag: String, _ msg: String) {
        print("\(time) ~ [ERROR | \(tag)]: \(msg)")
    }

    func e(_ tag: String, _ msg: String, _ exception: Exception) {
        print(
            "\(time) ~ [ERROR | \(tag)]: \(msg)\n"
                + "Happen in \(exception.happenFile):\(exception.happenLine)\n"
                + "Method: \(exception.happenFunction)\n"
                + "Message: \(exception.message)"
        )
    }
}

public final class Logger {

    private init() {}

    nonisolated(unsafe)
        fileprivate static var printer: LogPrinter = DefaultLogPrinter()

    public static func i(_ tag: String, _ msg: String) {
        printer.i(tag, msg)
    }

    public static func d(_ tag: String, _ msg: String) {
        printer.d(tag, msg)
    }

    public static func w(_ tag: String, _ msg: String) {
        printer.w(tag, msg)
    }

    public static func w(
        _ tag: String,
        _ msg: String,
        _ exception: Exception
    ) {
        printer.w(tag, msg, exception)
    }

    public static func e(_ tag: String, _ msg: String) {
        printer.e(tag, msg)
    }

    public static func e(
        _ tag: String,
        _ msg: String,
        _ exception: Exception
    ) {
        printer.e(tag, msg, exception)
    }
}

public func installLogPrinter(printer: LogPrinter) {
    Logger.printer = printer
}
