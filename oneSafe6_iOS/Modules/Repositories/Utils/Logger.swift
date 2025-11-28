//
//  Logger.swift
//  Repositories
//
//  Created by Lunabee Studio (Alexandre Cools) on 11/10/2022 - 4:43 PM.
//  Copyright © 2022 Lunabee Studio. All rights reserved.
//

import Foundation
import OSLog

// Make log function header compiling in prod.
struct DebugLogger {
    enum LogType { case ui, business, network }
    enum LogLevel { case log, debug, info, error, fault }
}

func log(type: DebugLogger.LogType, level: DebugLogger.LogLevel, message: @autoclosure @escaping () -> String) {
}

func log(_ error: @autoclosure @escaping () -> Error) {
    log(type: .business, level: .error, message: error().localizedDescription)
}

func logServer(request: URLRequest, response: HTTPURLResponse?, receivedData: Data?, error: Error? = nil) {
}
