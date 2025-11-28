//
//  BubblesSafeRepositoryImpl.swift
//  Repositories
//
//  Created by Lunabee Studio (François Combe) on 24/07/2024 - 11:48.
//  Copyright © 2024 Lunabee Studio. All rights reserved.
//

import Foundation
@preconcurrency import oneSafeKmp
import Storage
import Combine

final class BubblesSafeRepositoryImpl: BubblesSafeRepository {
    private let database: RealmManager = .shared
    static let mainSafeId: String = "d6cdd485-7171-46f3-8739-4401ad9d984b" // This will be improved when multi safe will be implemented.

    private var cancellables: Set<AnyCancellable> = []

    func __currentSafeId() async throws -> DoubleratchetDoubleRatchetUUID {
        try .companion.fromString(uuidString: Self.mainSafeId)
    }

    func currentSafeIdFlow() -> oneSafeKmp.SkieSwiftOptionalFlow<DoubleratchetDoubleRatchetUUID> {
        let wrapper: FlowNullableWrapper<DoubleratchetDoubleRatchetUUID> = .init()
        do {
            wrapper.emit(value: try .companion.fromString(uuidString: Self.mainSafeId))
            return wrapper.flow()
        } catch {
            fatalError("Coudn't convert \(Self.mainSafeId) into DoubleRatchetUUID")
        }
    }

    func isSafeReady() -> oneSafeKmp.SkieSwiftFlow<KotlinBoolean> {
        let wrapper: FlowWrapper<KotlinBoolean> = .init()
        database.isLoaded
            .sink { isLoaded in
                wrapper.emit(value: .init(bool: isLoaded))
            }
            .store(in: &cancellables)
        return wrapper.flow()
    }
}
