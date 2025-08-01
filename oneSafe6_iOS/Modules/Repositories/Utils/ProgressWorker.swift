//
//  ProgressWorker.swift
//  Repositories
//
//  Created by Lunabee Studio (Jérémy Magnier) on 05/03/2023 - 14:23.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import Combine
import Foundation

actor ProgressWorker {
    let progress: Progress
    let completedUnitCount: CurrentValueSubject<Int64, Never> = .init(0)
    let cancellable: AnyCancellable

    init(progress: Progress) {
        self.progress = progress
        cancellable = completedUnitCount
            .throttle(for: 0.05, scheduler: DispatchQueue(label: String(describing: ProgressWorker.self)), latest: true)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { value in
                progress.completedUnitCount = value
            })
    }

    deinit {
        RunLoop.main.perform { [progress, completedUnitCount] in
            progress.completedUnitCount = completedUnitCount.value
        }
    }

    func increment(_ value: Int) {
        completedUnitCount.value += Int64(value)
    }
}
