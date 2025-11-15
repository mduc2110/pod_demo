//
//  AppModule.swift
//  PrintOnDemand
//
//  Created by duczxje on 15/11/25.
//
public class AppModule: DependencyModule {
    public func install() {
        AppDependencies.appModule = self
    }
}

extension AppDependencies {
    nonisolated(unsafe) internal static var appModule: AppModule!
}
