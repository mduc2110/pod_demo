//
//  PlatformLogPrinter.swift
//  PrintOnDemand
//
//  Created by duczxje on 15/11/25.
//
import Foundation

class SwallowLogPrinter: LogPrinter {
    func i(_ tag: String, _ msg: String) {}
    func d(_ tag: String, _ msg: String) {}
    func w(_ tag: String, _ msg: String) {}
    func w(_ tag: String, _ msg: String, _ exception: any Exception) {}
    func e(_ tag: String, _ msg: String) {}
    func e(_ tag: String, _ msg: String, _ exception: any Exception) {}
}
