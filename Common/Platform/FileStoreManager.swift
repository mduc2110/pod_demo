import Foundation

public protocol FileStoreManager {
    func getFileURL(fileName: String) -> URL?
    
    func removeFile(fileName: String)
}
