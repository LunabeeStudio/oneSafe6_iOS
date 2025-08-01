//
//  Publisher+Extension.swift
//  Extensions
//
//  Created by Lunabee Studio (Nicolas) on 23/12/2022 - 11:22.
//  Copyright © 2022 Lunabee Studio. All rights reserved.
//

import Foundation
import Combine

public extension Publisher where Self.Failure == Never {
    func asyncMap<T>(transform: @escaping (_ values: Self.Output) async -> T) -> Publishers.FlatMap<Future<T, Never>, Self> {
        flatMap { values in
            Future { promise in
                Task {
                    await promise(.success(transform(values)))
                }
            }
        }
    }
}
