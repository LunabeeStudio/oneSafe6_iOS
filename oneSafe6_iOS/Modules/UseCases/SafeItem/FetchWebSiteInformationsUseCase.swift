//
//  FetchWebSiteInformationsUseCase.swift
//  UseCases
//
//  Created by Lunabee Studio (Alexandre Cools) on 17/11/2022 - 2:30 PM.
//  Copyright © 2022 Lunabee Studio. All rights reserved.
//

import Foundation
import UIKit
import Repositories

public struct FetchWebSiteInformationsUseCase {
    private let favIconRepository: FavIconRepository = .shared
    public init() { }

    public func invoke(for url: String?) async throws -> (icon: UIImage?, name: String?) {
        guard let url else { return (nil, nil) }
        return try await favIconRepository.fetchWebSiteInformations(for: url)
    }
}
