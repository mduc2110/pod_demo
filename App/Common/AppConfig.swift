//
//  AppConfig.swift
//  PrintOnDemand
//
//  Created by duczxje on 15/11/25.
//
import Foundation

public class AppConfig {
    private init() {}

    private static func getString(_ key: String) -> String? {
        (Bundle.main.infoDictionary?[key] as? String)?.replacingOccurrences(
            of: "\\",
            with: "",
        )
    }

    public static var BASE_URL: String = ""
}
