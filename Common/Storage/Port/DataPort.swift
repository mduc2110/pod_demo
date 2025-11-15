import Foundation

public protocol DataPort: AnyObject {
    var meta: String { get }
    func pull() throws -> Data
    func push(data: Data) throws
}
