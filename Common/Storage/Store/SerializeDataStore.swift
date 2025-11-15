import Foundation

open class SerializeDataStore<T: Codable>: DataStore {
    private let port: DataPort

    // Construct
    init(port: DataPort) {
        self.port = port
    }

    public var data: T? = nil

    public func load() {
        do {
            data = try JSONDecoder().decode(
                T.self,
                from: port.pull(),
            )
        } catch {
            Logger.e(
                "SerializeDataStore[\(port.meta)]",
                "Load() failed by \(error.getExceptionMessage())",
            )
        }
    }

    public func save() {
        do {
            try port.push(data: JSONEncoder().encode(self.data.require()))
        } catch {
            Logger.e(
                "SerializeDataStore[\(port.meta)]",
                "Save() failed by \(error.getExceptionMessage())",
            )
        }
    }

    deinit {
        cleanup()
    }

    @inline(never)
    private func cleanup() {
        data = nil
    }
}
