import Foundation

open class TextDataStore: DataStore {
    private let port: DataPort

    // Construct
    init(port: DataPort) {
        self.port = port
    }

    public var data: String = ""

    public func load() {
        do {
            data = String(data: try port.pull(), encoding: .utf8) ?? ""
        } catch {
            Logger.e(
                "TextDataStore[\(port.meta)]",
                "Load() failed by \(error.getExceptionMessage())",
            )
        }
    }

    public func save() {
        do {
            guard let pushedData = data.data(using: .utf8) else { return }
            try port.push(data: pushedData)
        } catch {
            Logger.e(
                "TextDataStore[\(port.meta)]",
                "Save() failed by \(error.getExceptionMessage())",
            )
        }
    }
}
