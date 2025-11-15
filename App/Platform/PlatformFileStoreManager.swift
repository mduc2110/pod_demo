//
//  PlatformFileStoreManager.swift
//  PrintOnDemand
//
//  Created by duczxje on 15/11/25.
//
import Foundation

private let APP_HOME_PATH = "PrintOnDemand"

final class PlatformFileStoreManager: FileStoreManager {
    private let fileManager: FileManager = .default

    init() {
        do {
            try setupHomeFolder()
        } catch {
            Logger.e(
                "PlatformFileStoreManager",
                "[FileStoreManager].init() failed by \(error.localizedDescription)"
            )
        }
    }

    func getFileURL(fileName: String) -> URL? {
        do {
            var url = try getHomeUrl()

            fileName.split(separator: "/").forEach { name in
                url = url.appendingPathComponent(String(name))
            }

            try ensureDirs(dirUrl: url.deletingLastPathComponent())

            return url
        } catch {
            Logger.e(
                "PlatformFileStoreManager",
                "[FileStoreManager].getFile() failed by \(error.localizedDescription)",
            )
            return nil
        }
    }

    func removeFile(fileName: String) {
        guard let url = getFileURL(fileName: fileName) else { return }
        guard fileManager.fileExists(atPath: url.path) else { return }
        do {
            try fileManager.removeItem(at: url)
        } catch {
            Logger.e(
                "PlatformFileStoreManager",
                "[FileStoreManager].removeFile() failed by \(error.localizedDescription)",
            )
        }
    }

    private func getRootUrl() throws -> URL {
        return try fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
        ).first.require()
    }

    private func getHomeUrl() throws -> URL {
        return try getRootUrl().appendingPathComponent(APP_HOME_PATH)
    }

    private func setupHomeFolder() throws {
        var homeUrl = try getHomeUrl()

        try ensureDirs(dirUrl: homeUrl)

        try homeUrl.setResourceValues(getExcludedBackupResourceValues())
    }

    private func ensureDirs(dirUrl: URL) throws {
        if fileManager.fileExists(atPath: dirUrl.path) { return }
        try fileManager.createDirectory(
            at: dirUrl,
            withIntermediateDirectories: true,
            attributes: nil
        )
    }

    private func getExcludedBackupResourceValues() -> URLResourceValues {
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true
        return resourceValues
    }
}
